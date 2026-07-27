import 'package:supabase_flutter/supabase_flutter.dart';

/// Lightweight authenticated-user representation used by the app UI.
class AppAuthUser {
  AppAuthUser({required this.email});

  final String email;
}

/// Authentication backed by Supabase Auth.
///
/// Accounts are keyed by the user's real email (so password-recovery codes can
/// be emailed to them), but users log in with their phone number. At sign-in we
/// look up the email for that phone from the `profiles` table, then sign in with
/// email + password under the hood.
class AuthService {
  SupabaseClient get _client => Supabase.instance.client;

  /// The currently signed-in Supabase user, or null.
  User? get currentUser => _client.auth.currentUser;

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
      },
    );
    return response.user;
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

  Future<void> signOut() => _client.auth.signOut();
}
