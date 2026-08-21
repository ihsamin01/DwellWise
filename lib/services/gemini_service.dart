import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:google_generative_ai/google_generative_ai.dart';

import '../config/ai_config.dart';
import '../models/property_model.dart';

/// Service interfacing with Google Gemini for the AI Recommended feed.
///
/// The API key is loaded lazily: a `--dart-define` override first, otherwise
/// the gitignored `assets/secrets/gemini.json`. If neither is available the
/// service stays disabled and callers fall back to the offline ranking.
class GeminiService {
  GenerativeModel? _model;
  bool _initialised = false;

  Future<void> _ensureInitialised() async {
    if (_initialised) return;
    _initialised = true;

    var key = AiConfig.geminiApiKeyOverride;
    if (key.isEmpty) {
      try {
        final raw = await rootBundle.loadString(AiConfig.secretsAsset);
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          key = (decoded['GEMINI_API_KEY'] as String?)?.trim() ?? '';
        }
      } catch (_) {
        // No local secrets file — stay disabled.
      }
    }

    if (key.isNotEmpty && !key.contains('your-key')) {
      _model = GenerativeModel(model: AiConfig.geminiModel, apiKey: key);
    }
  }

  /// The initialised model, or null when no API key is available.
  ///
  /// Exposed so other features (the assistant) reuse this one key-loading
  /// path instead of repeating it.
  Future<GenerativeModel?> model() async {
    await _ensureInitialised();
    return _model;
  }

  /// Asks Gemini to rank [candidates] for a user living at [userLocation] and
  /// returns the property ids ordered from most to least relevant. Returns an
  /// empty list on any error so the caller can fall back to local ranking.
  Future<List<String>> recommendPropertyIds({
    required String userLocation,
    required List<PropertyModel> candidates,
  }) async {
    if (candidates.isEmpty) return [];
    await _ensureInitialised();
    final model = _model;
    if (model == null) return [];

    final items = candidates
        .take(20)
        .map((p) =>
            '{"id":"${p.id}","area":"${_clean(p.area)}","title":"${_clean(p.title)}","price":${p.price.toInt()},"beds":${p.beds}}')
        .join(',');

    final prompt = 'You are DwellWise\'s rental recommendation engine. '
        'A user lives at: "$userLocation". '
        'From this list of rentals: [$items], return ONLY a JSON array of the '
        '"id" values, ordered from most to least relevant for someone living at '
        'that location (same/nearest area first). Return at most 10 ids and no '
        'other text. Example: ["p1","p3","p2"]';

    try {
      final response = await model.generateContent(
        [Content.text(prompt)],
      ).timeout(const Duration(seconds: 12));
      return _parseIds(response.text ?? '');
    } catch (_) {
      return [];
    }
  }

  List<String> _parseIds(String text) {
    final match = RegExp(r'\[.*\]', dotAll: true).firstMatch(text);
    if (match == null) return [];
    try {
      final decoded = jsonDecode(match.group(0)!);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    return [];
  }

  String _clean(String s) => s.replaceAll('"', "'").replaceAll('\n', ' ');
}
