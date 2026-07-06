import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPhoneMode = true; // true = Phone number, false = Email address
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate a premium response transition delay
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      });
    }
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // DwellWise Brand Logo representation
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.home_work_rounded,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'DwellWise',
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: AppColors.primary,
                      fontSize: 32,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Transparent Urban Rental Marketplace',
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Phone vs Email authentication mode selector tab
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.low,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isPhoneMode = true;
                                _identifierController.clear();
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _isPhoneMode ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Phone Number',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: _isPhoneMode ? Colors.white : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isPhoneMode = false;
                                _identifierController.clear();
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: !_isPhoneMode ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Email Address',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: !_isPhoneMode ? Colors.white : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Text Field - Email/Phone
                  TextFormField(
                    controller: _identifierController,
                    keyboardType: _isPhoneMode ? TextInputType.phone : TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: _isPhoneMode ? 'Mobile Number' : 'Email Address',
                      hintText: _isPhoneMode ? 'e.g. 01712345678' : 'e.g. name@domain.com',
                      prefixIcon: Icon(
                        _isPhoneMode ? Icons.phone_android_rounded : Icons.email_outlined,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return _isPhoneMode
                            ? 'Please enter your phone number'
                            : 'Please enter your email address';
                      }
                      if (!_isPhoneMode) {
                        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!emailRegex.hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                      } else {
                        if (value.length < 10) {
                          return 'Please enter a valid phone number';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),

                  // Text Field - Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your secure password',
                      prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
                        color: AppColors.textSecondary,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),

                  // Forgot Password Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Login CTA Button
                  CustomButton(
                    text: 'Sign In',
                    isLoading: _isLoading,
                    isPrimary: true, // uses brand primary color: #005C55
                    onPressed: _handleLogin,
                  ),
                  const SizedBox(height: 32),

                  // Divider line
                  Row(
                    children: [
                      const Expanded(child: Divider(color: AppColors.high, thickness: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Or Continue With',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: AppColors.high, thickness: 1)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Social Logins (Google & Facebook)
                  Row(
                    children: [
                      Expanded(
                        child: _SocialButton(
                          icon: Icons.g_mobiledata_rounded,
                          label: 'Google',
                          onTap: () {
                            // Mock social sign-in and direct navigation
                            Navigator.pushReplacementNamed(context, '/dashboard');
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _SocialButton(
                          icon: Icons.facebook_rounded,
                          label: 'Facebook',
                          onTap: () {
                            // Mock social sign-in and direct navigation
                            Navigator.pushReplacementNamed(context, '/dashboard');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Sign up toggle prompt
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: AppTextStyles.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          'Register Now',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.lowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.high, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: icon == Icons.g_mobiledata_rounded ? 36 : 22,
              color: icon == Icons.facebook_rounded ? const Color(0xff1877F2) : AppColors.textPrimary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
