import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/security_provider.dart';

/// Account status, security controls, and account deletion.
class AccountSecurityScreen extends StatelessWidget {
  const AccountSecurityScreen({super.key});

  void _showLogEntries(BuildContext context, String title, List<SecurityLogEntry> entries) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                ...entries.map(
                  (entry) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.devices_other_outlined),
                    title: Text(entry.title),
                    subtitle: Text(entry.subtitle),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xffDC2626)),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await context.read<SecurityProvider>().deleteAccount();
    if (!context.mounted) return;
    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;
    context.go('/login');
  }

  Widget _statusTile(String label, bool verified) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: Chip(
        label: Text(verified ? 'Verified' : 'Pending'),
        avatar: Icon(
          verified ? Icons.check_circle : Icons.hourglass_bottom,
          size: 16,
          color: verified ? const Color(0xff10B981) : const Color(0xffF59E0B),
        ),
        backgroundColor: (verified ? const Color(0xff10B981) : const Color(0xffF59E0B)).withOpacity(0.1),
        labelStyle: TextStyle(color: verified ? const Color(0xff10B981) : const Color(0xffF59E0B)),
        side: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final security = context.watch<SecurityProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Account & Security')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Account Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  _statusTile('Email Verified', security.isEmailVerified),
                  const Divider(height: 1),
                  _statusTile('Phone Verified', security.isPhoneVerified),
                  const Divider(height: 1),
                  _statusTile('Government ID Verification', security.isGovIdVerified),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Security', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Change Password'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/profile/change-password'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.devices_outlined),
                  title: const Text('Active Login Sessions'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showLogEntries(context, 'Active Login Sessions', security.activeSessions),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.verified_user_outlined),
                  title: const Text('Trusted Devices'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showLogEntries(context, 'Trusted Devices', security.trustedDevices),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Login History'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showLogEntries(context, 'Login History', security.loginHistory),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Authentication', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.shield_outlined),
                  title: const Text('Two-Factor Authentication'),
                  value: security.twoFactorEnabled,
                  onChanged: security.setTwoFactorEnabled,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.fingerprint),
                  title: const Text('Biometric Login'),
                  value: security.biometricEnabled,
                  onChanged: security.setBiometricEnabled,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Danger Zone', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xffDC2626))),
          Card(
            color: const Color(0xffFEF2F2),
            child: ListTile(
              leading: const Icon(Icons.delete_forever_outlined, color: Color(0xffDC2626)),
              title: const Text('Delete Account', style: TextStyle(color: Color(0xffDC2626), fontWeight: FontWeight.bold)),
              onTap: () => _confirmDeleteAccount(context),
            ),
          ),
        ],
      ),
    );
  }
}
