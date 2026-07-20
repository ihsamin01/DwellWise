import 'package:flutter/material.dart';

/// Scrollable Privacy Policy page.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _sections = [
    (
      'Information We Collect',
      'We collect information you provide directly, such as your name, phone '
          'number, email address, and listing or search details, as well as '
          'device and usage information collected automatically.',
    ),
    (
      'How We Use Your Information',
      'Your information is used to operate the platform: matching tenants '
          'with listings, enabling messaging between users, sending relevant '
          'notifications, and improving the DwellWise experience.',
    ),
    (
      'Data Security',
      'We apply industry-standard safeguards to protect your data against '
          'unauthorized access, alteration, or disclosure. No method of '
          'transmission over the internet is 100% secure.',
    ),
    (
      'Cookies',
      'DwellWise may use cookies and similar technologies to remember your '
          'preferences, keep you signed in, and understand how the app is used.',
    ),
    (
      'Third-party Services',
      'We may rely on third-party services (such as maps and cloud hosting) '
          'that process limited data on our behalf, solely to provide app '
          'functionality.',
    ),
    (
      'User Rights',
      'You may access, correct, or request deletion of your personal '
          'information at any time from the Account & Security page.',
    ),
    (
      'Data Retention',
      'We retain personal data only as long as necessary to provide our '
          'services or as required by law, after which it is securely deleted.',
    ),
    (
      'Contact Information',
      'Questions about this policy can be sent to support@dwellwise.com.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'This Privacy Policy explains how DwellWise collects, uses, and protects your information.',
            style: TextStyle(color: Color(0xff6B7280)),
          ),
          const SizedBox(height: 20),
          for (final section in _sections) ...[
            Text(section.$1, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(section.$2, style: const TextStyle(height: 1.5, color: Color(0xff374151))),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}
