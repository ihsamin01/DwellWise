import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';
import '../../widgets/custom_button.dart';

/// Landing screen for landlords displaying metrics dashboard and quick shortcuts.
class OwnerHomeScreen extends StatelessWidget {
  const OwnerHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('DwellWise Landlord'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_pin),
            onPressed: () => context.push('/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: () {
              userProvider.switchPerspective(UserRole.tenant);
              context.go('/tenant-home');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'My Property Portfolio',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            
            // Bento statistics cards row
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard('Total Properties', '2', Icons.home),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard('Active Inquiries', '3', Icons.mark_chat_unread_outlined),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            CustomButton(
              text: 'List New Property',
              onPressed: () => context.push('/create-listing'),
            ),
            const SizedBox(height: 28),
            
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Quick Shortcuts',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            ListTile(
              leading: const Icon(Icons.list_alt, color: Color(0xff1E40AF)),
              title: const Text('Manage Listings'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () => context.push('/my-listings'),
            ),
            ListTile(
              leading: const Icon(Icons.question_answer_outlined, color: Color(0xff1E40AF)),
              title: const Text('Review Applications'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () => context.push('/owner-inquiries'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String val, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xff1E40AF)),
            const SizedBox(height: 16),
            Text(val, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
