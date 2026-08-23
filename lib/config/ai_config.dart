/// Google Gemini configuration for the AI Recommended feed.
class AiConfig {
  AiConfig._();

  /// Optional compile-time override; empty unless --dart-define is used.
  static const String geminiApiKeyOverride =
      String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  /// Asset that holds the local key.
  static const String secretsAsset = 'assets/secrets/gemini.json';

  /// The alias, not a pinned model.
  static const String geminiModel = 'gemini-flash-latest';
}
