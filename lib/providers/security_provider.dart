import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';
import '../services/fingerprint_auth_service.dart';

/// A single device/session/history entry shown on the Account & Security page.
class SecurityLogEntry {
  final String title;
  final String subtitle;

  const SecurityLogEntry({required this.title, required this.subtitle});
}

/// Provider handling account security preferences.
class SecurityProvider with ChangeNotifier {
  bool _isEmailVerified = true;
  bool _isPhoneVerified = true;

  final AuthService _authService = AuthService();
  final FingerprintAuthService _fingerprintAuth = FingerprintAuthService();

  String? _errorMessage;

  /// Why the last [changePassword], [deleteAccount], or fingerprint call
  /// failed.
  String? get errorMessage => _errorMessage;

  bool _fingerprintUnlockEnabled = false;
  bool _fingerprintBusy = false;

  bool get isEmailVerified => _isEmailVerified;
  bool get isPhoneVerified => _isPhoneVerified;

  bool get fingerprintUnlockEnabled => _fingerprintUnlockEnabled;
  bool get fingerprintBusy => _fingerprintBusy;

  final List<SecurityLogEntry> activeSessions = const [
    SecurityLogEntry(title: 'Chrome on Windows', subtitle: 'Dhaka, Bangladesh · Active now'),
    SecurityLogEntry(title: 'DwellWise App on Android', subtitle: 'Dhaka, Bangladesh · 2 hours ago'),
  ];

  final List<SecurityLogEntry> loginHistory = const [
    SecurityLogEntry(title: 'Successful login', subtitle: 'Dhaka, Bangladesh · 20 Jul 2026, 9:14 AM'),
    SecurityLogEntry(title: 'Successful login', subtitle: 'Dhaka, Bangladesh · 18 Jul 2026, 8:02 PM'),
    SecurityLogEntry(title: 'Password changed', subtitle: 'Dhaka, Bangladesh · 15 Jul 2026, 6:45 PM'),
  ];

  /// Loads the saved Fingerprint Unlock preference for the signed-in user.
  /// Call when the Account & Security screen opens.
  Future<void> loadFingerprintUnlockStatus() async {
    final userId = _authService.currentUser?.id;
    if (userId == null) return;
    _fingerprintUnlockEnabled = await _fingerprintAuth.isEnabledForUser(userId);
    notifyListeners();
  }

  /// Verifies the device can authenticate with a fingerprint, runs the
  /// native fingerprint prompt, and only then saves the preference. Never
  /// stores fingerprint data or the user's password.
  Future<bool> enableFingerprintUnlock() async {
    final userId = _authService.currentUser?.id;
    if (userId == null) {
      _errorMessage = 'You need to be signed in to enable Fingerprint Unlock.';
      notifyListeners();
      return false;
    }

    _errorMessage = null;
    _fingerprintBusy = true;
    notifyListeners();

    try {
      final available = await _fingerprintAuth.isFingerprintAvailable();
      if (!available) {
        _errorMessage =
            'Fingerprint authentication is not available on this device.';
        return false;
      }

      final authenticated = await _fingerprintAuth.authenticate(
        reason: 'Verify your fingerprint to enable Fingerprint Unlock',
      );
      if (!authenticated) {
        return false;
      }

      await _fingerprintAuth.setEnabledForUser(userId, true);
      _fingerprintUnlockEnabled = true;
      return true;
    } finally {
      _fingerprintBusy = false;
      notifyListeners();
    }
  }

  /// Turns Fingerprint Unlock off for the signed-in user on this device.
  Future<void> disableFingerprintUnlock() async {
    final userId = _authService.currentUser?.id;
    if (userId != null) {
      await _fingerprintAuth.setEnabledForUser(userId, false);
    }
    _fingerprintUnlockEnabled = false;
    notifyListeners();
  }

  /// Changes the account password.
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

  /// Permanently deletes the account.
  Future<bool> deleteAccount() async {
    _errorMessage = null;
    try {
      await _authService.deleteAccount();
      _isEmailVerified = false;
      _isPhoneVerified = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }
}
