import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../data/bd_area_coordinates.dart';
import '../models/property_model.dart';
import '../utils/language_detect.dart';
import '../utils/property_matcher.dart';
import 'gemini_service.dart';
import 'supabase_service.dart';

/// What the user's message turned out to be.
class Interpretation {
  const Interpretation.search(this.intent)
      : reply = null,
        isSearch = true;
  const Interpretation.chat(this.reply)
      : intent = null,
        isSearch = false;

  final bool isSearch;
  final SearchIntent? intent;

  /// Already written in the user's language.
  final String? reply;
}

/// Thrown when Gemini could not be reached at all.
class AssistantUnavailable implements Exception {
  const AssistantUnavailable();
}

/// Listings found for an intent, plus how far the search had to reach.
class AssistantSearchResult {
  const AssistantSearchResult({
    required this.matches,
    required this.radiusKm,
    required this.widened,
    this.cheaperNearby = const [],
  });

  /// Best first, already filtered to the score threshold.
  final List<MatchResult> matches;

  /// How far out the search ended up going.
  final double? radiusKm;

  /// True when nothing was found in the requested area itself.
  final bool widened;

  /// In-budget listings slightly further out.
  final List<MatchResult> cheaperNearby;

  bool get isEmpty => matches.isEmpty && cheaperNearby.isEmpty;
}

/// The assistant's brain.
class AssistantService {
  final GeminiService _gemini = GeminiService();
  final SupabaseService _db = SupabaseService();

  /// How far the search widens, in order, when the area name finds nothing.
  static const List<double> _radiusSteps = [5, 10];

  /// Listings shown in the chat.
  static const int displayLimit = 6;

  // ── reading the request ────────────────────────────────────────────────

  /// Works out whether [message] is a search and, if so, what for.
  Future<Interpretation?> interpret(
    String message, {
    SearchIntent? previous,
  }) async {
    final model = await _gemini.model();
    if (model == null) return null;

    final known = previous == null
        ? '{}'
        : jsonEncode(previous.toJson());

    // Decided here, not by the model.
    final language = detectLanguage(message);
    final languageName = language == 'bn' ? 'Bangla' : 'English';

    final prompt = '''
You are the assistant inside DwellWise, a Bangladeshi rental app. You return
JSON only.

The user may write in Bangla, English or a mix of both. Understand either.

Decide which of two things the message is.

If they are looking for a place to rent, return:
{"mode":"search", "area":..., "property_type":..., "beds":..., "baths":...,
 "balcony":..., "max_rent":..., "facilities":[...]}
  "area"          English place name, e.g. "ECB Chattar", "Banani", "Mirpur 10"
  "property_type" one of: Family, Bachelor, Office room, Sublet, Hostel
  "beds","baths","balcony"  integers
  "max_rent"      integer, monthly taka
  "facilities"    array from: GAS, LIFT, CCTV, GARAGE
Only include a key the user actually stated or clearly implied.
Translate place names to their English form. "ইসিবি" is "ECB Chattar".
"family basha" means Family. "bachelor" means Bachelor. "3 room" means beds 3.
Merge with what is already known: $known

Otherwise — a greeting, a thank you, a question about the app or about
renting — return:
{"mode":"chat", "reply":"..."}
  Answer the question that was actually asked, in one or two short sentences.
  Write the reply in $languageName. If Bangla, use Bangla script and Bangla
  digits, never Bangla in English letters.
  Never name or invent a property, price, or how many listings exist — you
  cannot see the catalogue here. If they seem to want a home, ask which area
  to search.

Return the JSON object and nothing else.

User message: "${_clean(message)}"
''';

    final text = await _generate(model, prompt);
    if (text == null) throw const AssistantUnavailable();
    return _parseInterpretation(text, previous, language);
  }

  /// Runs [prompt], retrying a couple of times before giving up.
  Future<String?> _generate(GenerativeModel model, String prompt) async {
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final response = await model
            .generateContent([Content.text(prompt)])
            .timeout(const Duration(seconds: 12));
        final text = response.text?.trim();
        if (text != null && text.isNotEmpty) return text;
      } catch (_) {
        // Fall through to the next attempt.
      }
      if (attempt < 2) {
        // Seconds, not milliseconds.
        await Future<void>.delayed(
            Duration(milliseconds: 600 * (attempt + 1)));
      }
    }
    return null;
  }

  Interpretation? _parseInterpretation(
    String text,
    SearchIntent? previous,
    String language,
  ) {
    final match = RegExp(r'\{.*\}', dotAll: true).firstMatch(text);
    if (match == null) return null;

    try {
      final decoded = jsonDecode(match.group(0)!);
      if (decoded is! Map) return null;

      if (decoded['mode'] == 'chat') {
        final reply = _asString(decoded['reply']);
        return reply == null ? null : Interpretation.chat(reply);
      }

      final facilities = <String>[
        for (final f in (decoded['facilities'] as List? ?? const []))
          f.toString().toUpperCase(),
      ];

      return Interpretation.search(SearchIntent(
        area: _asString(decoded['area']) ?? previous?.area,
        propertyType:
            _asString(decoded['property_type']) ?? previous?.propertyType,
        beds: _asInt(decoded['beds']) ?? previous?.beds,
        baths: _asInt(decoded['baths']) ?? previous?.baths,
        balcony: _asInt(decoded['balcony']) ?? previous?.balcony,
        maxRent: _asInt(decoded['max_rent'])?.toDouble() ?? previous?.maxRent,
        facilities:
            facilities.isNotEmpty ? facilities : (previous?.facilities ?? const []),
        language: language,
      ));
    } catch (_) {
      return null;
    }
  }

  // ── finding real listings ──────────────────────────────────────────────

  /// Searches by area name first.
  Future<AssistantSearchResult> search(SearchIntent intent) async {
    final area = intent.area;
    if (area == null || area.trim().isEmpty) {
      return const AssistantSearchResult(
          matches: [], radiusKm: null, widened: false);
    }

    // 1.
    final byName = await _db.getApprovedPropertiesInArea(area);
    final named = rankProperties(byName, intent);
    if (named.isNotEmpty) {
      return AssistantSearchResult(
        matches: named,
        radiusKm: null,
        widened: false,
        cheaperNearby: await _cheaperNearby(intent, named),
      );
    }

    // 2.
    final point = coordinatesFor(area);
    for (final radius in _radiusSteps) {
      final nearby = await _db.getApprovedPropertiesNear(
        latitude: point.$1,
        longitude: point.$2,
        radiusKm: radius,
      );
      final within = _withinRadius(nearby, point, radius);
      final ranked = rankProperties(within, intent);
      if (ranked.isNotEmpty) {
        return AssistantSearchResult(
          matches: ranked,
          radiusKm: radius,
          widened: true,
        );
      }
    }

    return const AssistantSearchResult(
        matches: [], radiusKm: null, widened: false);
  }

  /// In-budget listings a little further out.
  Future<List<MatchResult>> _cheaperNearby(
    SearchIntent intent,
    List<MatchResult> found,
  ) async {
    final budget = intent.maxRent;
    if (budget == null || budget <= 0) return [];

    // Only worth offering when the area itself came up short on budget.
    final inBudget = found.where((m) => !m.isOverBudget).length;
    if (inBudget >= 3) return [];

    final point = coordinatesFor(intent.area!);
    final nearby = await _db.getApprovedPropertiesNear(
      latitude: point.$1,
      longitude: point.$2,
      radiusKm: 3,
    );

    final seen = found.map((m) => m.property.id).toSet();
    final affordable = [
      for (final p in _withinRadius(nearby, point, 3))
        if (p.price <= budget && !seen.contains(p.id)) p,
    ];

    return rankProperties(affordable, intent).take(3).toList();
  }

  List<PropertyModel> _withinRadius(
    List<PropertyModel> properties,
    (double, double) point,
    double radiusKm,
  ) {
    return [
      for (final p in properties)
        if (p.latitude != 0 &&
            p.longitude != 0 &&
            distanceKm(point.$1, point.$2, p.latitude, p.longitude) <= radiusKm)
          p,
    ];
  }

  // ── wording the answer ─────────────────────────────────────────────────

  /// Writes the reply from the listings that were actually found.
  Future<String> writeReply({
    required SearchIntent intent,
    required AssistantSearchResult result,
  }) async {
    // Nothing to describe, so there is no point spending a call and a second
    // on it.
    if (result.isEmpty) return _fallbackReply(intent, result);

    final model = await _gemini.model();
    if (model == null) return _fallbackReply(intent, result);

    final shown = result.matches.take(displayLimit).toList();
    final listings = [
      for (var i = 0; i < shown.length; i++)
        '${i + 1}. ${_describe(shown[i])}',
    ].join('\n');

    final cheaper = result.cheaperNearby.isEmpty
        ? ''
        : '\nCheaper within 3km:\n${[
            for (final m in result.cheaperNearby) '- ${_describe(m)}',
          ].join('\n')}';

    final language = intent.isBangla
        ? 'Reply in proper Bangla. Use Bangla script throughout, including '
            'numbers (১, ২, ৩) and taka amounts. Do not write Bangla in '
            'English letters.'
        : 'Reply in English.';

    final kind = intent.propertyType == null
        ? 'matching'
        : '${intent.propertyType} ';
    final widened = result.widened
        ? 'There are no ${kind}listings in ${intent.area} itself. These are '
            'within ${result.radiusKm?.toInt()} km of it. Say that plainly in '
            'the first line before listing anything.'
        : '';

    final prompt = '''
You are DwellWise's rental assistant, helping someone who is new to the app.

$language
Be brief — a short opening line, then one sentence per listing at most.
$widened

Describe ONLY the listings below. Never invent a property, price or feature.
Do not write links, ids or numbers of your own.
When several match, say which one you would pick and why, using the reasons
given.

The user asked for: ${jsonEncode(intent.toJson())}

Listings found:
$listings$cheaper
''';

    // A failure here is survivable.
    final text = await _generate(model, prompt);
    return text ?? _fallbackReply(intent, result);
  }

  String _describe(MatchResult m) {
    final p = m.property;
    final parts = <String>[
      p.title,
      '${p.beds} bed',
      '${p.baths} bath',
      'BDT ${p.price.round()}/month',
      p.area,
      if (p.facilities.isNotEmpty) 'has ${p.facilities.join(', ')}',
      'match ${m.score.round()}%',
      if (m.shortfalls.isNotEmpty) 'shortfalls: ${m.shortfalls.join('; ')}',
    ];
    return parts.join(' — ');
  }

  /// Used when Gemini is unavailable.
  String _fallbackReply(SearchIntent intent, AssistantSearchResult result) {
    if (result.isEmpty) {
      return intent.isBangla
          ? 'দুঃখিত, আপনার চাহিদার সাথে মেলে এমন কোনো বাসা এখন পাওয়া যাচ্ছে না।'
          : 'Sorry, nothing matching your requirements is available right now.';
    }
    final count = result.matches.take(displayLimit).length;
    return intent.isBangla
        ? 'আপনার চাহিদার সাথে $count টি বাসা মিলেছে।'
        : 'Found $count listings matching your requirements.';
  }

  String _clean(String s) => s.replaceAll('"', "'").replaceAll('\n', ' ');

  static String? _asString(Object? value) {
    if (value == null) return null;
    final s = value.toString().trim();
    return s.isEmpty ? null : s;
  }

  static int? _asInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value.toString());
  }
}
