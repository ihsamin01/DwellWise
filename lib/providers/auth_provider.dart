import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

/// Provider handling global Authentication status and state changes.
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  AppAuthUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AppAuthUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    // Restore any persisted Supabase session on app start.
    final user = _authService.currentUser;
    if (user != null) {
      _currentUser = AppAuthUser(email: user.email ?? '');
    }
  }

  /// Signs in with phone + password.
  Future<bool> login(String phone, String password) async {
    _setLoading(true);
    _clearError();
    try {
      final user = await _authService.signIn(phone: phone, password: password);
      if (user == null) {
        _setError('Login failed. Please try again.');
        return false;
      }
      _currentUser = AppAuthUser(email: user.email ?? '');
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Registers a new account (name + phone + email + password).
  Future<bool> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    String? address,
    String role = 'tenant',
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final user = await _authService.register(
        name: name,
        phone: phone,
        email: email,
        password: password,
        address: address,
        role: role,
      );
      if (user == null) {
        _setError('Registration failed. Please try again.');
        return false;
      }
      _currentUser = AppAuthUser(email: user.email ?? '');
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// "Continue with Google". Returns the raw result so the screen can decide:
  /// success → go home; notRegistered → go to the register page.
  Future<GoogleSignInResult> signInWithGoogle() async {
    _setLoading(true);
    _clearError();
    try {
      final result = await _authService.signInWithGoogle();
      if (result.outcome == GoogleSignInOutcome.success) {
        final user = _authService.currentUser;
        _currentUser = AppAuthUser(email: user?.email ?? result.email ?? '');
        notifyListeners();
      } else if (result.outcome == GoogleSignInOutcome.failed) {
        _setError(result.errorMessage ?? 'Google sign-in failed.');
      }
      return result;
    } finally {
      _setLoading(false);
    }
  }

  /// Forgot-password step 1: email a recovery code to [email].
  Future<bool> sendPasswordResetCode(String email) async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.sendPasswordResetCode(email);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Forgot-password step 2: verify [code] and set [newPassword]. On success the
  /// session is cleared so the user signs in fresh.
  Future<bool> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.verifyCodeAndSetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
      );
      _currentUser = null;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Phone OTP is not wired yet (needs a paid SMS provider). Kept as a no-op so
  /// the OTP screen still builds.
  Future<void> sendOtp(
      String phoneNumber, Function(String, int?) codeSent) async {}

  /// Sign out current user session.
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void _setError(String msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
