import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// Fingerprint Unlock: device capability checks, the native fingerprint
/// prompt, and the per-user/per-device enabled preference.
///
/// Only the enabled/disabled flag is ever stored -- never fingerprint data
/// or the user's password. The actual biometric match happens entirely
/// inside the OS (Android BiometricPrompt), this app never sees it.
class FingerprintAuthService {
  FingerprintAuthService();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Backs isFingerprintAvailable() on Android -- see the comment there for
  // why local_auth alone can't answer this on that platform. Implemented
  // natively in MainActivity.kt via FingerprintManagerCompat.
  static const MethodChannel _androidFingerprintChannel =
      MethodChannel('dwellwise.fingerprint/availability');

  static String _prefKey(String userId) => 'dw_fingerprint_unlock_$userId';

  /// Whether this device has a fingerprint sensor with at least one
  /// fingerprint enrolled. Deliberately excludes Face ID / face unlock.
  Future<bool> isFingerprintAvailable() async {
    try {
      final supported = await _localAuth.isDeviceSupported();
      final canCheck = await _localAuth.canCheckBiometrics;
      if (!supported || !canCheck) return false;

      if (Platform.isAndroid) {
        // Android's BiometricManager (which local_auth_android wraps) only
        // ever reports the authenticator *strength* class -- BIOMETRIC_STRONG
        // / BIOMETRIC_WEAK, surfaced in Dart as BiometricType.strong/.weak --
        // never which sensor backs it. So `getAvailableBiometrics()` can
        // never contain BiometricType.fingerprint on Android, even on a
        // Samsung phone unlocked with a fingerprint every day. Ask the
        // fingerprint sensor directly instead of relying on that enum.
        try {
          final hasFingerprint = await _androidFingerprintChannel
              .invokeMethod<bool>('hasEnrolledFingerprint');
          return hasFingerprint ?? false;
        } on MissingPluginException {
          return false;
        }
      }

      // iOS/macOS reliably distinguish Touch ID (.fingerprint) from Face ID
      // (.face) in getAvailableBiometrics(), so the enum check is accurate
      // there.
      final available = await _localAuth.getAvailableBiometrics();
      return available.contains(BiometricType.fingerprint);
    } on PlatformException {
      return false;
    }
  }

  /// Shows the native fingerprint prompt. Returns true only on a
  /// successful fingerprint match.
  Future<bool> authenticate({required String reason}) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }

  Future<bool> isEnabledForUser(String userId) async {
    final value = await _storage.read(key: _prefKey(userId));
    return value == 'true';
  }

  Future<void> setEnabledForUser(String userId, bool enabled) async {
    if (enabled) {
      await _storage.write(key: _prefKey(userId), value: 'true');
    } else {
      await _storage.delete(key: _prefKey(userId));
    }
  }
}
