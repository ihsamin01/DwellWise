import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Scrollable Terms & Conditions with an "I Agree" acknowledgement button
/// (demo only — no account flag is actually set).
class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  static const _sections = [
    (
      'User Responsibilities',
      'Users must provide accurate personal and contact information, use the '
          'platform only for lawful residential search or listing purposes, and '
          'promptly update their account details if they change.',
    ),
    (
      'Property Listing Rules',
      'Owners must list only properties they have the legal right to rent, '
          'provide accurate descriptions, pricing, and photos, and keep listing '
          'availability up to date.',
    ),
    (
      'Rental Agreement Disclaimer',
      'DwellWise facilitates introductions between tenants and owners only. Any '
          'rental agreement, deposit, or move-in arrangement is made directly '
          'between the two parties and is not managed or guaranteed by DwellWise.',
    ),
    (
      'Payment Disclaimer',
      'DwellWise does not process rent payments, security deposits, or advance '
          'payments between tenants and owners. Users are advised to verify '
          'identities and property documents before making any payment.',
    ),
    (
      'Privacy Notice',
      'Personal information submitted to DwellWise is handled in accordance '
          'with our Privacy Policy and is used only to operate and improve the '
          'platform.',
    ),
    (
      'Prohibited Activities',
      'Posting fraudulent listings, harassment of other users, scraping the '
          'platform, and circumventing verification checks are strictly '
          'prohibited and may result in account suspension.',
    ),
    (
      'Account Suspension Policy',
      'DwellWise reserves the right to suspend or terminate accounts that '
          'violate these terms, submit false information, or engage in abusive '
          'behavior toward other users.',
    ),
    (
      'Liability Disclaimer',
      'DwellWise is provided "as is" without warranties of any kind. We are '
          'not liable for disputes, losses, or damages arising from '
          'interactions between tenants and property owners.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms & Conditions')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(
                    'Please read these Terms & Conditions carefully before using DwellWise.',
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
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Thanks for confirming!')),
                      );
                      context.pop();
                    },
                    child: const Text('I Agree'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
