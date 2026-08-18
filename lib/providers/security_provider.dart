import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';

/// A single device/session/history entry shown on the Account & Security page.
class SecurityLogEntry {
  final String title;
  final String subtitle;

  const SecurityLogEntry({required this.title, required this.subtitle});
}

/// Provider handling account security preferences: verification status,
/// 2FA/biometric toggles, and session/device/login-history mock data.
class SecurityProvider with ChangeNotifier {
  bool _isEmailVerified = true;
  bool _isPhoneVerified = true;

  final AuthService _authService = AuthService();

  String? _errorMessage;

  /// Why the last [changePassword] or [deleteAccount] call failed.
  String? get errorMessage => _errorMessage;

  bool _twoFactorEnabled = false;
  bool _biometricEnabled = false;

  bool get isEmailVerified => _isEmailVerified;
  bool get isPhoneVerified => _isPhoneVerified;

  bool get twoFactorEnabled => _twoFactorEnabled;
  bool get biometricEnabled => _biometricEnabled;

  final List<SecurityLogEntry> activeSessions = const [
    SecurityLogEntry(title: 'Chrome on Windows', subtitle: 'Dhaka, Bangladesh · Active now'),
    SecurityLogEntry(title: 'DwellWise App on Android', subtitle: 'Dhaka, Bangladesh · 2 hours ago'),
  ];

  final List<SecurityLogEntry> loginHistory = const [
    SecurityLogEntry(title: 'Successful login', subtitle: 'Dhaka, Bangladesh · 20 Jul 2026, 9:14 AM'),
    SecurityLogEntry(title: 'Successful login', subtitle: 'Dhaka, Bangladesh · 18 Jul 2026, 8:02 PM'),
    SecurityLogEntry(title: 'Password changed', subtitle: 'Dhaka, Bangladesh · 15 Jul 2026, 6:45 PM'),
  ];

  void setTwoFactorEnabled(bool value) {
    _twoFactorEnabled = value;
    notifyListeners();
  }

  void setBiometricEnabled(bool value) {
    _biometricEnabled = value;
    notifyListeners();
  }

  /// Changes the account password. Returns false and sets [errorMessage] when
  /// the current password is wrong or Supabase refuses the new one.
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _errorMessage = null;
    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  /// Simulates account deletion. No backend to call — just clears local flags.
  Future<void> deleteAccount() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _isEmailVerified = false;
    _isPhoneVerified = false;
    notifyListeners();
  }
}
