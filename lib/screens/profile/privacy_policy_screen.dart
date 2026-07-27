import 'package:flutter/material.dart';

/// Scrollable Privacy Policy page.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _sections = [
    (
      Icons.assignment_outlined,
      'Information We Collect',
      'We collect information you provide directly, such as your name, phone '
          'number, email address, and listing or search details, as well as '
          'device and usage information collected automatically.',
    ),
    (
      Icons.vpn_key_outlined,
      'How We Use Your Information',
      'Your information is used to operate the platform: matching tenants '
          'with listings, enabling messaging between users, sending relevant '
          'notifications, and improving the DwellWise experience.',
    ),
    (
      Icons.shield_outlined,
      'Data Security',
      'We apply industry-standard safeguards to protect your data against '
          'unauthorized access, alteration, or disclosure. No method of '
          'transmission over the internet is 100% secure.',
    ),
    (
      Icons.cookie_outlined,
      'Cookies',
      'DwellWise may use cookies and similar technologies to remember your '
          'preferences, keep you signed in, and understand how the app is used.',
    ),
    (
      Icons.public_outlined,
      'Third-party Services',
      'We may rely on third-party services (such as maps and cloud hosting) '
          'that process limited data on our behalf, solely to provide app '
          'functionality.',
    ),
    (
      Icons.person_outline,
      'User Rights',
      'You may access, correct, or request deletion of your personal '
          'information at any time from the Account & Security page.',
    ),
    (
      Icons.folder_outlined,
      'Data Retention',
      'We retain personal data only as long as necessary to provide our '
          'services or as required by law, after which it is securely deleted.',
    ),
    (
      Icons.call_outlined,
      'Contact Information',
      'Questions about this policy can be sent to support@dwellwise.com.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          physics: const BouncingScrollPhysics(),
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.privacy_tip_outlined, color: colorScheme.onPrimaryContainer),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This Privacy Policy explains how DwellWise collects, uses, and protects your information.',
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section cards
            for (final section in _sections)
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 1.5,
                shadowColor: colorScheme.shadow.withOpacity(0.15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(section.$1, color: colorScheme.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              section.$2,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        section.$3,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
