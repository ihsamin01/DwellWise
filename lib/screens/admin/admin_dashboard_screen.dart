import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Screen representing administrative statistics dashboard.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Text(
            'System Controls',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          _buildControlTile(
            context,
            title: 'Pending Approvals',
            subtitle: 'Properties awaiting physical coordinates validation checks.',
            icon: Icons.pending_actions,
            route: '/pending-listings',
          ),
          const SizedBox(height: 16),
          _buildControlTile(
            context,
            title: 'Reported Listings',
            subtitle: 'Properties flagged for fraud or duplicate details.',
            icon: Icons.report_problem_outlined,
            route: '/reported-listings',
          ),
        ],
      ),
    );
  }

  Widget _buildControlTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String route,
  }) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Icon(icon, size: 36, color: const Color(0xff0F766E)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(route),
      ),
    );
  }
}
