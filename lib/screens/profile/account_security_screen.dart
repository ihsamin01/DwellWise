import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/security_provider.dart';
import '../../providers/recently_viewed_provider.dart';
import '../../providers/saved_properties_provider.dart';
import '../../providers/user_provider.dart';

/// Account status, security controls, and account deletion.
class AccountSecurityScreen extends StatefulWidget {
  const AccountSecurityScreen({super.key});

  @override
  State<AccountSecurityScreen> createState() => _AccountSecurityScreenState();
}

class _AccountSecurityScreenState extends State<AccountSecurityScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<SecurityProvider>().loadFingerprintUnlockStatus();
    });
  }

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

    final security = context.read<SecurityProvider>();
    final deleted = await security.deleteAccount();
    if (!context.mounted) return;

    // Only tear the session down if the account really went.
    if (!deleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(security.errorMessage ?? 'Could not delete the account.'),
          backgroundColor: const Color(0xffDC2626),
        ),
      );
      return;
    }

    // Captured before the awaits.
    final messenger = ScaffoldMessenger.of(context);

    context.read<SavedPropertiesProvider>().clear();
    context.read<RecentlyViewedProvider>().clear();
    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;

    context.go('/login');
    messenger.showSnackBar(
      const SnackBar(
        content: Text(
          'Account deleted successfully. Register again to use DwellWise.',
        ),
        backgroundColor: Color(0xff10B981),
        duration: Duration(seconds: 5),
      ),
    );
  }

  /// [value] shows the verified data point (email/phone/masked ID) as a.
  Widget _statusTile({
    required String label,
    required bool verified,
    String? value,
    VoidCallback? onBadgeTap,
  }) {
    final color = verified ? const Color(0xff10B981) : const Color(0xff1877F2);
    final badge = Chip(
      label: Text(verified ? 'Verified' : 'Pending'),
      avatar: Icon(
        verified ? Icons.check_circle : Icons.hourglass_bottom,
        size: 16,
        color: color,
      ),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color),
      side: BorderSide.none,
    );

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: value != null ? Text(value) : null,
      trailing: onBadgeTap != null
          ? InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onBadgeTap,
              child: badge,
            )
          : badge,
    );
  }

  Future<void> _handleEnableFingerprint(BuildContext context) async {
    final security = context.read<SecurityProvider>();
    final success = await security.enableFingerprintUnlock();
    if (!context.mounted || success) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          security.errorMessage ?? 'Could not enable Fingerprint Unlock.',
        ),
        backgroundColor: const Color(0xffDC2626),
      ),
    );
  }

  /// Masks a submitted NID/passport number down to its last 4 digits,.
  String _maskGovernmentId(String id) {
    if (id.length <= 4) return id;
    return '${'*' * 12}${id.substring(id.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    final security = context.watch<SecurityProvider>();
    final user = context.watch<UserProvider>().userModel;
    final isGovIdVerified = user?.verificationStatus == VerificationStatus.verified;

    return Scaffold(
      appBar: AppBar(title: const Text('Account & Security')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, 20 + MediaQuery.viewPaddingOf(context).bottom),
        children: [
          const Text('Account Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  _statusTile(
                    label: 'Email Verification',
                    verified: security.isEmailVerified,
                    value: user?.email,
                  ),
                  const Divider(height: 1),
                  _statusTile(
                    label: 'Phone Verification',
                    verified: security.isPhoneVerified,
                    value: user?.phoneNumber,
                  ),
                  const Divider(height: 1),
                  _statusTile(
                    label: 'Government ID Verification',
                    verified: isGovIdVerified,
                    value: isGovIdVerified && user?.governmentId != null
                        ? _maskGovernmentId(user!.governmentId!)
                        : null,
                    onBadgeTap: isGovIdVerified ? null : () => context.push('/profile/verification'),
                  ),
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.fingerprint),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Fingerprint Unlock',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Use your fingerprint to quickly unlock your DwellWise account.',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: security.fingerprintUnlockEnabled
                              ? OutlinedButton(
                                  onPressed: security.fingerprintBusy
                                      ? null
                                      : () => security.disableFingerprintUnlock(),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xffDC2626),
                                    side: const BorderSide(color: Color(0xffDC2626)),
                                  ),
                                  child: const Text('Disable'),
                                )
                              : ElevatedButton(
                                  onPressed: security.fingerprintBusy
                                      ? null
                                      : () => _handleEnableFingerprint(context),
                                  child: security.fingerprintBusy
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : const Text('Enable Fingerprint Unlock'),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            color: const Color(0xffDC2626).withOpacity(0.08),
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
