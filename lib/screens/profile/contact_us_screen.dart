import 'package:flutter/material.dart';

/// Static support contact details. Actions are demo-only Snackbars — no
/// dialer/mailer/maps integration is wired up.
class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  static const _phone = '+880-1700-000000';
  static const _email = 'support@dwellwise.com';
  static const _address = 'House 12, Road 5, Gulshan 1, Dhaka 1212, Bangladesh';
  static const _hours = 'Sunday – Thursday, 9:00 AM – 6:00 PM';

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Us')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        child: Icon(Icons.support_agent, color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text('Customer Support', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ],
                  ),
                  const Divider(height: 28),
                  const _InfoRow(icon: Icons.phone_outlined, label: 'Phone', value: _phone),
                  const SizedBox(height: 14),
                  const _InfoRow(icon: Icons.email_outlined, label: 'Email', value: _email),
                  const SizedBox(height: 14),
                  const _InfoRow(icon: Icons.location_on_outlined, label: 'Office Address', value: _address),
                  const SizedBox(height: 14),
                  const _InfoRow(icon: Icons.schedule_outlined, label: 'Support Hours', value: _hours),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _showSnackBar(context, 'Calling $_phone'),
              icon: const Icon(Icons.call),
              label: const Text('Call Now'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => _showSnackBar(context, 'Opening email to $_email'),
              icon: const Icon(Icons.email_outlined),
              label: const Text('Email Us'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => _showSnackBar(context, 'Opening directions to our office'),
              icon: const Icon(Icons.directions_outlined),
              label: const Text('Get Directions'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xff6B7280)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Color(0xff6B7280))),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}
