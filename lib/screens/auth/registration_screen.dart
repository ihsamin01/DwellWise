import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_colors.dart';
import '../../providers/auth_provider.dart';

/// Screen representing user registration page.
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full Name is required';
    }
    if (value.trim().length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone Number is required';
    }
    // Matches 10 digits after +880 (e.g. 1712345678)
    final phoneRegex = RegExp(r'^1[3-9]\d{8}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Enter a valid mobile number (e.g. 1712345678)';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Current Address is required';
    }
    return null;
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();

      // Call auth register stub
      final success = await authProvider.register(
        '+880${_phoneController.text.trim()}',
        _passwordController.text,
      );

      if (success && mounted) {
        // Success feedback
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Please log in.'),
            backgroundColor: Color(0xff10B981), // Success Emerald Green
          ),
        );
        // Redirect to Login Screen
        context.go('/login');
      } else if (mounted) {
        final errorMsg = authProvider.errorMessage ?? 'Registration failed.';
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
          backgroundColor: Color(0xffDC2626), // Error Red
        ),
      );
    }
  }

  Widget _buildInputLabel(AppColors colors, String labelText, bool isRequired) {
    if (!isRequired) {
      return Text(
        labelText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: colors.textSecondary,
        ),
      );
    }
    return RichText(
      text: TextSpan(
        text: labelText.replaceAll(' *', ''),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: colors.textSecondary,
        ),
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(
              color: Color(0xffDC2626), // Error Red
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isLoading = context.watch<AuthProvider>().isLoading;

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

                // Top Badge and Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: colors.textSecondary),
                      onPressed: () => context.pop(),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: colors.placeholder,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Step 1 of 2',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Centered DwellWise Logo
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

                // Heading
                Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Join DwellWise to find or list verified rentals',
                  style: TextStyle(
                    fontSize: 15,
                    color: colors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Full Name Input
                _buildInputLabel(colors, 'FULL NAME *', true),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  style: TextStyle(color: colors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Enter your full name',
                    hintStyle: TextStyle(color: colors.textSecondary),
                    fillColor: colors.surface,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    prefixIcon: Icon(Icons.person_outline, color: colors.textSecondary),
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
                      borderSide: const BorderSide(color: Color(0xffDC2626), width: 1.5),
                    ),
                  ),
                  validator: _validateName,
                ),
                const SizedBox(height: 20), // Form vertical gap

                // Phone Number Input
                _buildInputLabel(colors, 'PHONE NUMBER *', true),
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                      borderSide: const BorderSide(color: Color(0xffDC2626), width: 1.5),
                    ),
                  ),
                  validator: _validatePhone,
                ),
                const SizedBox(height: 20), // Form vertical gap

                // Password Input
                _buildInputLabel(colors, 'PASSWORD *', true),
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    prefixIcon: Icon(Icons.lock_outline, color: colors.textSecondary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
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
                      borderSide: const BorderSide(color: Color(0xffDC2626), width: 1.5),
                    ),
                  ),
                  validator: _validatePassword,
                ),
                const SizedBox(height: 6),
                Text(
                  'Min 6 characters',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20), // Form vertical gap

                // Current Address Input
                _buildInputLabel(colors, 'CURRENT ADDRESS *', true),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _addressController,
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                  style: TextStyle(color: colors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Building address, street, area',
                    hintStyle: TextStyle(color: colors.textSecondary),
                    fillColor: colors.surface,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    prefixIcon: Icon(Icons.location_on_outlined, color: colors.textSecondary),
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
                      borderSide: const BorderSide(color: Color(0xffDC2626), width: 1.5),
                    ),
                  ),
                  validator: _validateAddress,
                ),
                const SizedBox(height: 32),

                // Register Button
                _CTAButton(
                  text: 'Register',
                  isLoading: isLoading,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 24),

                // Bottom Login prompt
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(fontSize: 14, color: colors.textSecondary),
                    ),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Text(
                        'Log In',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Security Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lock_outline, size: 14, color: colors.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          'SECURE ENCRYPTION',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colors.textSecondary),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.gavel_outlined, size: 14, color: colors.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          'LEGAL COMPLIANCE',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                // Footer lines
                Text(
                  '© 2024 DwellWise. All rights reserved.',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Footer Links
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Privacy',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.primary),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('|', style: TextStyle(fontSize: 12, color: colors.textSecondary)),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Terms of Service',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.primary),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('|', style: TextStyle(fontSize: 12, color: colors.textSecondary)),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Contact Support',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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
    Color bg = const Color(0xffF59E0B);
    if (_isPressed) {
      bg = const Color(0xffE59E0B);
    }

    return GestureDetector(
      onTapDown: widget.isLoading ? null : (_) => setState(() => _isPressed = true),
      onTapUp: widget.isLoading ? null : (_) => setState(() => _isPressed = false),
      onTapCancel: widget.isLoading ? null : () => setState(() => _isPressed = false),
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
