import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';

/// Screen representing user login page.
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

/// Which sign-in the user started.
enum _SignInMethod { none, password, google }

class _LoginScreenState extends State<LoginScreen> {
  _SignInMethod _inFlight = _SignInMethod.none;
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _keepMeSignedIn = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your phone number';
    }
    // Matches 10 digits after +880 (e.g.
    final phoneRegex = RegExp(r'^1[3-9]\d{8}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Please enter a valid mobile number (e.g. 1712345678)';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _handleGoogleSignIn() async {
    if (_inFlight != _SignInMethod.none) return;
    setState(() => _inFlight = _SignInMethod.google);

    final authProvider = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();
    final result = await authProvider.signInWithGoogle();
    if (!mounted) return;
    setState(() => _inFlight = _SignInMethod.none);

    switch (result.outcome) {
      case GoogleSignInOutcome.success:
        await authProvider.setKeepSignedIn(_keepMeSignedIn);
        await userProvider.loadCurrentUserProfile();
        if (!mounted) return;
        context.go('/tenant-home');
        break;
      case GoogleSignInOutcome.notRegistered:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${result.email ?? 'This account'} is not registered. Please register first.'),
            backgroundColor: const Color(0xffDC2626),
          ),
        );
        // Carry the Google email/name across so the account is registered under.
        context.push(
          Uri(
            path: '/register',
            queryParameters: <String, String>{
              if (result.email != null) 'email': result.email!,
              if (result.name != null) 'name': result.name!,
            },
          ).toString(),
        );
        break;
      case GoogleSignInOutcome.cancelled:
        break;
      case GoogleSignInOutcome.failed:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(authProvider.errorMessage ?? 'Google sign-in failed.'),
            backgroundColor: const Color(0xffDC2626),
          ),
        );
        break;
    }
  }

  void _handleSignIn() async {
    if (_formKey.currentState!.validate()) {
      if (_inFlight != _SignInMethod.none) return;
      setState(() => _inFlight = _SignInMethod.password);

      final authProvider = context.read<AuthProvider>();
      final userProvider = context.read<UserProvider>();

      final success = await authProvider.login(
        '+880${_phoneController.text.trim()}',
        _passwordController.text,
      );

      if (mounted) setState(() => _inFlight = _SignInMethod.none);

      if (success && mounted) {
        await authProvider.setKeepSignedIn(_keepMeSignedIn);
        await userProvider.loadCurrentUserProfile();
        if (!mounted) return;
        context.go('/tenant-home');
      } else if (mounted) {
        final errorMsg = authProvider.errorMessage ??
            'Login failed. Please check credentials.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: const Color(0xffDC2626), // Error Red
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please correct the validation errors in the form'),
          backgroundColor: Color(0xffDC2626),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40), // Top Spacing

                // Centered Logo.
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: colors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.home_work_rounded,
                      size: 40,
                      color: colors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Welcome Headings.
                Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Find your next perfect dwelling in Bangladesh',
                  style: TextStyle(
                    fontSize: 16,
                    color: colors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Form section - Phone Number.
                Text(
                  'PHONE NUMBER',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(color: colors.textPrimary),
                  decoration: InputDecoration(
                    hintText: '1XXX-XXXXXX',
                    hintStyle: TextStyle(color: colors.textSecondary),
                    fillColor: colors.surface,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    prefixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 16),
                        Icon(Icons.phone_outlined, color: colors.textSecondary),
                        const SizedBox(width: 8),
                        Text(
                          '+880',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 1,
                          height: 24,
                          color: colors.border,
                        ),
                        const SizedBox(width: 12),
                      ],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colors.primary, width: 1.5),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xffDC2626)),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                          color: Color(0xffDC2626), width: 1.5),
                    ),
                  ),
                  validator: _validatePhone,
                ),
                const SizedBox(height: 20), // Form vertical gap

                // Password Field.
                Text(
                  'PASSWORD',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: TextStyle(color: colors.textPrimary),
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    hintStyle: TextStyle(color: colors.textSecondary),
                    fillColor: colors.surface,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    prefixIcon:
                        Icon(Icons.lock_outline, color: colors.textSecondary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: colors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colors.primary, width: 1.5),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xffDC2626)),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                          color: Color(0xffDC2626), width: 1.5),
                    ),
                  ),
                  validator: _validatePassword,
                ),
                const SizedBox(height: 16),

                // Keep me signed in & Forgot password row.
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _keepMeSignedIn,
                            activeColor: colors.primary,
                            onChanged: (val) {
                              setState(() {
                                _keepMeSignedIn = val ?? false;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Keep me signed in',
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => context.push('/forgot-password'),
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24), // Section gap

                // Sign In Button.
                _CTAButton(
                  text: 'Sign In',
                  isLoading: _inFlight == _SignInMethod.password,
                  onPressed: _handleSignIn,
                ),
                const SizedBox(height: 24),

                // OR Continue section.
                Row(
                  children: [
                    Expanded(child: Divider(color: colors.border)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'OR CONTINUE WITH',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: colors.border)),
                  ],
                ),
                const SizedBox(height: 20),

                // Google sign-in button ONLY (No Facebook button).
                _GoogleSignInButton(
                  isLoading: _inFlight == _SignInMethod.google,
                  onTap: _handleGoogleSignIn,
                ),
                const SizedBox(height: 32),

                // Bottom register section.
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style:
                          TextStyle(fontSize: 14, color: colors.textSecondary),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/register'),
                      child: Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CTAButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const _CTAButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<_CTAButton> createState() => _CTAButtonState();
}

class _CTAButtonState extends State<_CTAButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    Color bg = const Color(0xff1877F2); // CTA Orange
    if (_isPressed) {
      bg = const Color(0xffE59E0B); // Pressed Darker Orange
    }

    return GestureDetector(
      onTapDown:
          widget.isLoading ? null : (_) => setState(() => _isPressed = true),
      onTapUp:
          widget.isLoading ? null : (_) => setState(() => _isPressed = false),
      onTapCancel:
          widget.isLoading ? null : () => setState(() => _isPressed = false),
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: 56,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: widget.isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                widget.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLoading;

  const _GoogleSignInButton({
    Key? key,
    required this.onTap,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xffDADCE0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: isLoading
            // Sized to the Google 'G' so swapping it for the spinner does not.
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xff3C4043)),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/google_g.svg',
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Continue with Google',
                    style: TextStyle(
                      // Google brand guideline text colour (dark grey).
                      color: Color(0xff3C4043),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
