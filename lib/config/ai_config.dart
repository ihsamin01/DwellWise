/// Google Gemini configuration for the AI Recommended feed.
///
/// The key is never committed. At runtime [GeminiService] reads it from
/// `assets/secrets/gemini.json` (gitignored — see the README in that folder):
///
///   { "GEMINI_API_KEY": "your-key" }
///
/// A `--dart-define=GEMINI_API_KEY=...` build flag still overrides it if given,
/// but plain `flutter run` works because of the asset file.
///
/// With no key at all the app keeps working: the AI Recommended feed falls back
/// to the offline location-based ranking.
class AiConfig {
  AiConfig._();

  /// Optional compile-time override; empty unless --dart-define is used.
  static const String geminiApiKeyOverride =
      String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  /// Asset that holds the local key.
  static const String secretsAsset = 'assets/secrets/gemini.json';

  static const String geminiModel = 'gemini-flash-latest';
}
