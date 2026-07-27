import 'package:flutter/material.dart';

/// Scrollable Terms & Conditions with an "I Agree" acknowledgement button
/// (demo only — no account flag is actually set). Agreeing shows a success
/// message but deliberately stays on this page — the user leaves only via
/// the back button, never an automatic redirect.
class TermsConditionsScreen extends StatefulWidget {
  const TermsConditionsScreen({super.key});

  @override
  State<TermsConditionsScreen> createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends State<TermsConditionsScreen> {
  static const _sections = [
    (
      Icons.person_outline,
      'User Responsibilities',
      'Users must provide accurate personal and contact information, use the '
          'platform only for lawful residential search or listing purposes, and '
          'promptly update their account details if they change.',
    ),
    (
      Icons.home_outlined,
      'Property Listing Rules',
      'Owners must list only properties they have the legal right to rent, '
          'provide accurate descriptions, pricing, and photos, and keep listing '
          'availability up to date.',
    ),
    (
      Icons.description_outlined,
      'Rental Agreement Disclaimer',
      'DwellWise facilitates introductions between tenants and owners only. Any '
          'rental agreement, deposit, or move-in arrangement is made directly '
          'between the two parties and is not managed or guaranteed by DwellWise.',
    ),
    (
      Icons.payments_outlined,
      'Payment Disclaimer',
      'DwellWise does not process rent payments, security deposits, or advance '
          'payments between tenants and owners. Users are advised to verify '
          'identities and property documents before making any payment.',
    ),
    (
      Icons.lock_outline,
      'Privacy Notice',
      'Personal information submitted to DwellWise is handled in accordance '
          'with our Privacy Policy and is used only to operate and improve the '
          'platform.',
    ),
    (
      Icons.warning_amber_outlined,
      'Prohibited Activities',
      'Posting fraudulent listings, harassment of other users, scraping the '
          'platform, and circumventing verification checks are strictly '
          'prohibited and may result in account suspension.',
    ),
    (
      Icons.gavel_outlined,
      'Account Suspension Policy',
      'DwellWise reserves the right to suspend or terminate accounts that '
          'violate these terms, submit false information, or engage in abusive '
          'behavior toward other users.',
    ),
    (
      Icons.shield_outlined,
      'Liability Disclaimer',
      'DwellWise is provided "as is" without warranties of any kind. We are '
          'not liable for disputes, losses, or damages arising from '
          'interactions between tenants and property owners.',
    ),
  ];

  bool _agreed = false;

  void _handleAgree() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Expanded(child: Text('Terms & Conditions accepted successfully.')),
          ],
        ),
        backgroundColor: Color(0xff10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      ),
    );
    // Deliberately stays on this page — no pop/redirect. The user leaves via
    // the back button whenever they choose.
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
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
                        Icon(Icons.description_outlined, color: colorScheme.onPrimaryContainer),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Please read these Terms & Conditions carefully before using DwellWise.',
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

            // Sticky bottom action area
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => setState(() => _agreed = !_agreed),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Checkbox(
                                value: _agreed,
                                onChanged: (value) => setState(() => _agreed = value ?? false),
                              ),
                              Expanded(
                                child: Text(
                                  'I have read and agree to the Terms & Conditions',
                                  style: TextStyle(fontSize: 13.5, color: colorScheme.onSurface),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _agreed ? _handleAgree : null,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('I Agree', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
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
