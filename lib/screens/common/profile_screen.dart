import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';
import '../../widgets/custom_button.dart';

/// Screen displaying profile updates and perspective swaps.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final authProvider = context.watch<AuthProvider>();
    
    final user = userProvider.userModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: const Color(0xff0F766E).withOpacity(0.1),
                child: const Icon(Icons.person, size: 48, color: Color(0xff0F766E)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              user?.name ?? 'Samin Azhan',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              user?.email ?? authProvider.currentUser?.email ?? 'samin@dwellwise.com',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            const Text('Perspective View', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      userProvider.switchPerspective(UserRole.tenant);
                      context.go('/tenant-home');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: user?.role == UserRole.tenant ? const Color(0xff0F766E) : Colors.grey.shade300,
                    ),
                    child: const Text('Tenant'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      userProvider.switchPerspective(UserRole.owner);
                      context.go('/owner-home');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: user?.role == UserRole.owner ? const Color(0xff0F766E) : Colors.grey.shade300,
                    ),
                    child: const Text('Landlord'),
                  ),
                ),
              ],
            ),
            const Spacer(),
            CustomButton(
              text: 'Edit Profile Settings',
              onPressed: () => context.push('/profile/edit'),
            ),
          ],
        ),
      ),
    );
  }
}
