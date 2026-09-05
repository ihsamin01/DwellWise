import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../utils/friendly_error.dart';

/// Lightweight authenticated-user representation used by the app UI.
class AppAuthUser {
  AppAuthUser({required this.email});

  final String email;
}

/// Outcome of a "Continue with Google" attempt.
enum GoogleSignInOutcome { success, notRegistered, cancelled, failed }

/// Which registration detail is already in use by another account.
enum AccountConflict { none, email, phone, both }

class GoogleSignInResult {
  GoogleSignInResult(this.outcome, {this.email, this.name, this.errorMessage});

  final GoogleSignInOutcome outcome;
  final String? email;
  final String? name;
  final String? errorMessage;
}

/// Authentication backed by Supabase Auth.
class AuthService {
  SupabaseClient get _client => Supabase.instance.client;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: SupabaseConfig.googleWebClientId,
    scopes: const ['email', 'profile'],
  );

  static const String _keepSignedInKey = 'dw_keep_signed_in';

  /// The currently signed-in Supabase user, or null.
  User? get currentUser => _client.auth.currentUser;

  /// Remembers whether the user opted to stay signed in across app restarts.
  Future<void> setKeepSignedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keepSignedInKey, value);
  }

  /// Called on startup.
  Future<void> applySessionPersistencePolicy() async {
    final prefs = await SharedPreferences.getInstance();
    final keep = prefs.getBool(_keepSignedInKey) ?? true;
    if (!keep && currentUser != null) {
      try {
        await _client.auth.signOut();
      } on AuthException catch (_) {
        // Offline, or Supabase unreachable.
      }
    }
  }

  /// Signs in with phone + password (resolves the phone to its email first).
  Future<User?> signIn({
    required String phone,
    required String password,
  }) async {
    // Ordered by created_at.
    final rows = await _client
        .from('profiles')
        .select('email')
        .eq('phone_number', phone)
        .order('created_at', ascending: true)
        .limit(1);

    if (rows.isEmpty) {
      throw const AuthException('No account found for this phone number.');
    }
    final email = rows.first['email'] as String?;
    if (email == null || email.isEmpty) {
      throw const AuthException('This account has no email on file.');
    }

    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response.user;
  }

  /// Which of the registration details already belong to an existing account.
  Future<AccountConflict> findAccountConflict({
    required String email,
    required String phone,
  }) async {
    final rows = await _client
        .from('profiles')
        .select('email, phone_number')
        .or('email.ilike.$email,phone_number.eq.$phone');

    var emailTaken = false;
    var phoneTaken = false;
    for (final row in rows) {
      final rowEmail = (row['email'] as String?) ?? '';
      if (rowEmail.toLowerCase() == email.toLowerCase()) emailTaken = true;
      if (row['phone_number'] == phone) phoneTaken = true;
    }

    if (emailTaken && phoneTaken) return AccountConflict.both;
    if (emailTaken) return AccountConflict.email;
    if (phoneTaken) return AccountConflict.phone;
    return AccountConflict.none;
  }

  /// Registers a new account with a real email.
  Future<User?> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    String? address,
    String? gender,
    String role = 'tenant',
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'name': name,
        'phone_number': phone,
        'role': role,
        if (address != null && address.isNotEmpty) 'address': address,
        if (gender != null && gender.isNotEmpty) 'gender': gender,
      },
    );

    // The DB trigger creates the profile from name/phone/role only.
    final user = response.user;
    if (user != null) {
      final updates = <String, dynamic>{};
      if (address != null && address.isNotEmpty) updates['address'] = address;
      if (gender != null && gender.isNotEmpty) updates['gender'] = gender;
      if (updates.isNotEmpty) {
        try {
          await _client.from('profiles').update(updates).eq('id', user.id);
        } catch (_) {
          // Non-fatal.
        }
      }
    }
    return user;
  }

  /// "Continue with Google".
  Future<GoogleSignInResult> signInWithGoogle() async {
    try {
      // Start from a clean slate so the account picker always shows.
      await _googleSignIn.signOut();

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return GoogleSignInResult(GoogleSignInOutcome.cancelled);
      }
      final email = googleUser.email;

      // Is this email already registered through the app's form?
      final rows = await _client
          .from('profiles')
          .select('email')
          .eq('email', email)
          .limit(1);

      if (rows.isEmpty) {
        await _googleSignIn.signOut();
        return GoogleSignInResult(
          GoogleSignInOutcome.notRegistered,
          email: email,
          name: googleUser.displayName,
        );
      }

      // Registered → complete the Supabase sign-in with the Google ID token.
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        await _googleSignIn.signOut();
        return GoogleSignInResult(
          GoogleSignInOutcome.failed,
          errorMessage: 'Could not get a Google ID token.',
        );
      }

      await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: googleAuth.accessToken,
      );
      return GoogleSignInResult(GoogleSignInOutcome.success, email: email);
    } catch (e) {
      return GoogleSignInResult(
        GoogleSignInOutcome.failed,
        errorMessage: friendlyError(e),
      );
    }
  }

  /// Changes the signed-in user's password, after checking the current one.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final email = currentUser?.email;
    if (email == null) {
      throw const AuthException('You need to be signed in to change your password.');
    }

    try {
      await _client.auth.signInWithPassword(
        email: email,
        password: currentPassword,
      );
    } on AuthException {
      throw const AuthException('Your current password is incorrect.');
    }

    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  /// Step 1 of recovery.
  Future<void> sendPasswordResetCode(String email) async {
    await _client.auth.signInWithOtp(
      email: email,
      shouldCreateUser: false,
    );
  }

  /// Step 2 of recovery.
  Future<void> verifyCodeAndSetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await _client.auth.verifyOTP(
      email: email,
      token: code,
      type: OtpType.email,
    );
    await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
    await _client.auth.signOut();
  }

  /// Permanently deletes the signed-in user's account.
  Future<void> deleteAccount() async {
    if (currentUser == null) {
      throw const AuthException('You need to be signed in to delete your account.');
    }

    try {
      await _client.functions.invoke('delete-account');
    } on FunctionException catch (e) {
      // invoke() throws on any non-2xx rather than returning the status.
      throw AuthException(
        e.status == 404
            ? 'Account deletion is not available yet — the delete-account '
                'function has not been deployed.'
            : 'Could not delete the account. Please try again.',
      );
    }

    await signOut();
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _client.auth.signOut();
  }
}
