import 'package:flutter/material.dart';

/// Supported app languages. Add a new value here (and a matching column in
/// [AppStrings]) to support another language.
enum AppLanguage { english, bangla }

/// Provider handling the user's selected display language.
class LocaleProvider with ChangeNotifier {
  AppLanguage _language = AppLanguage.english;

  AppLanguage get language => _language;

  String get languageCode => _language == AppLanguage.bangla ? 'bn' : 'en';

  void setLanguage(AppLanguage language) {
    if (_language == language) return;
    _language = language;
    notifyListeners();
  }
}
