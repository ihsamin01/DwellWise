/// Google Gemini configuration for the AI Recommended feed.
class AiConfig {
  AiConfig._();

  /// Optional compile-time override; empty unless --dart-define is used.
  static const String geminiApiKeyOverride =
      String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  /// Asset that holds the local key.
  static const String secretsAsset = 'assets/secrets/gemini.json';

  /// Flash-Lite: the plain flash alias started answering 429 under the free
  /// tier, and every refusal cost a retry, so replies took several seconds or
  /// failed outright. This answers in about a second and its Bangla is just
  /// as good.
  static const String geminiModel = 'gemini-flash-lite-latest';
}
