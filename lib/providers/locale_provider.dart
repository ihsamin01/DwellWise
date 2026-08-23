import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported app languages.
enum AppLanguage { english, bangla }

/// Provider handling the user's selected display language.
class LocaleProvider with ChangeNotifier {
  static const String _storageKey = 'dw_language';

  AppLanguage _language = AppLanguage.english;

  AppLanguage get language => _language;

  String get languageCode => _language == AppLanguage.bangla ? 'bn' : 'en';

  LocaleProvider() {
    _restore();
  }

  void setLanguage(AppLanguage language) {
    if (_language == language) return;
    _language = language;
    notifyListeners();
    _persist(language);
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_storageKey);
    if (stored != 'bn' || _language == AppLanguage.bangla) return;
    _language = AppLanguage.bangla;
    notifyListeners();
  }

  Future<void> _persist(AppLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      language == AppLanguage.bangla ? 'bn' : 'en',
    );
  }
}
