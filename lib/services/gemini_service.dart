import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../config/ai_config.dart';
import '../models/property_model.dart';

/// Service interfacing with Google Gemini for the AI Recommended feed.
class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: AiConfig.geminiModel,
      apiKey: AiConfig.geminiApiKey,
    );
  }

  bool get isConfigured =>
      AiConfig.geminiApiKey.isNotEmpty &&
      !AiConfig.geminiApiKey.contains('YOUR_');

  /// Asks Gemini to rank [candidates] for a user living at [userLocation] and
  /// returns the property ids ordered from most to least relevant. Returns an
  /// empty list on any error so the caller can fall back to local ranking.
  Future<List<String>> recommendPropertyIds({
    required String userLocation,
    required List<PropertyModel> candidates,
  }) async {
    if (!isConfigured || candidates.isEmpty) return [];

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
      final response = await _model
          .generateContent([Content.text(prompt)]).timeout(
        const Duration(seconds: 12),
      );
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
