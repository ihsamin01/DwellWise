import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider handling the user's Light / Dark / System theme preference.
class ThemeProvider with ChangeNotifier {
  static const String _storageKey = 'dw_theme_mode';

  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _restore();
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    _persist(mode);
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_storageKey);
    if (stored == null) return;
    final restored = _decode(stored);
    if (restored == _themeMode) return;
    _themeMode = restored;
    notifyListeners();
  }

  Future<void> _persist(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, _encode(mode));
  }

  // Stored by name rather than index so reordering ThemeMode upstream cannot.
  static String _encode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
      case ThemeMode.light:
        return 'light';
    }
  }

  static ThemeMode _decode(String value) {
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }
}
