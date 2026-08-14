import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';

/// Lightweight authenticated-user representation used by the app UI.
class AppAuthUser {
  AppAuthUser({required this.email});

  final String email;
}

/// Outcome of a "Continue with Google" attempt.
enum GoogleSignInOutcome { success, notRegistered, cancelled, failed }

class GoogleSignInResult {
  GoogleSignInResult(this.outcome, {this.email, this.name, this.errorMessage});

  final GoogleSignInOutcome outcome;
  final String? email;
  final String? name;
  final String? errorMessage;
}

/// Authentication backed by Supabase Auth.
///
/// Accounts are keyed by the user's real email (so password-recovery codes can
/// be emailed to them), but users log in with their phone number. At sign-in we
/// look up the email for that phone from the `profiles` table, then sign in with
/// email + password under the hood.
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

  /// Called on startup: if the user did NOT choose "keep me signed in", clear
  /// the restored session so they must log in again after leaving the app.
  Future<void> applySessionPersistencePolicy() async {
    final prefs = await SharedPreferences.getInstance();
    final keep = prefs.getBool(_keepSignedInKey) ?? false;
    if (!keep && currentUser != null) {
      try {
        await _client.auth.signOut();
      } on AuthException catch (_) {
        // Offline, or Supabase unreachable. gotrue drops the local session
        // before it ever calls the server, so the policy has already been
        // applied — the failed server-side logout is not worth crashing
        // startup over, which is what an uncaught throw here would do.
      }
    }
  }

  /// Signs in with phone + password (resolves the phone to its email first).
  Future<User?> signIn({
    required String phone,
    required String password,
  }) async {
    final rows = await _client
        .from('profiles')
        .select('email')
        .eq('phone_number', phone)
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

  /// Registers a new account with a real email. Name/phone/role are stored as
  /// user metadata so the database trigger can create the `profiles` row.
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

    // The DB trigger creates the profile from name/phone/role only, so persist
    // the address + gender onto the freshly-created profile row here.
    final user = response.user;
    if (user != null) {
      final updates = <String, dynamic>{};
      if (address != null && address.isNotEmpty) updates['address'] = address;
      if (gender != null && gender.isNotEmpty) updates['gender'] = gender;
      if (updates.isNotEmpty) {
        try {
          await _client.from('profiles').update(updates).eq('id', user.id);
        } catch (_) {
          // Non-fatal: the account is still created.
        }
      }
    }
    return user;
  }

  /// "Continue with Google": shows the native account picker, then only logs
  /// the user in if their email is already registered in `profiles`. Otherwise
  /// returns [GoogleSignInOutcome.notRegistered] so the UI can send them to the
  /// registration screen (no Supabase account is created in that case).
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
        errorMessage: e.toString(),
      );
    }
  }

  /// Step 1 of recovery: emails a 6-digit code to [email] (only if an account
  /// with that email exists).
  Future<void> sendPasswordResetCode(String email) async {
    await _client.auth.signInWithOtp(
      email: email,
      shouldCreateUser: false,
    );
  }

  /// Step 2 of recovery: verifies the emailed [code], sets [newPassword], then
  /// signs back out so the user logs in fresh with their new password.
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

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _client.auth.signOut();
  }
}
