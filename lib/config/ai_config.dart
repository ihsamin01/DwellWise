/// Google Gemini configuration for the AI Recommended feed.
///
/// The key is NOT stored in source control. It is injected at build time:
///
///   flutter run   --dart-define-from-file=env.json
///   flutter build apk --dart-define-from-file=env.json
///
/// `env.json` (gitignored) looks like:
///   { "GEMINI_API_KEY": "your-key-here" }
///
/// When no key is supplied, [isConfigured] is false and the AI Recommended feed
/// falls back to the offline location-based ranking, so the app still works.
class AiConfig {
  AiConfig._();

  static const String geminiApiKey =
      String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  static const String geminiModel = 'gemini-flash-latest';
}
