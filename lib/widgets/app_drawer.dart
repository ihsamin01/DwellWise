import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../config/app_strings.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';

/// App-wide navigation drawer opened from the hamburger icon, listing
/// account/profile/settings destinations.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<UserProvider>().userModel;

    void navigateTo(String path) {
      Navigator.of(context).pop();
      context.push(path);
    }

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: theme.colorScheme.primary),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    backgroundImage: (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty)
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                    child: (user?.avatarUrl == null || user!.avatarUrl!.isEmpty)
                        ? const Icon(Icons.person, color: Colors.white, size: 28)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          user?.name ?? 'Guest',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 4),
                children: [
                  _DrawerTile(
                    icon: Icons.edit_outlined,
                    label: AppStrings.t(context, 'menu_edit_profile'),
                    onTap: () => navigateTo('/profile/edit'),
                  ),
                  _DrawerTile(
                    icon: Icons.lock_outline,
                    label: AppStrings.t(context, 'menu_change_password'),
                    onTap: () => navigateTo('/profile/change-password'),
                  ),
                  _DrawerTile(
                    icon: Icons.security_outlined,
                    label: AppStrings.t(context, 'menu_account_security'),
                    onTap: () => navigateTo('/profile/security'),
                  ),
                  _DrawerTile(
                    icon: Icons.notifications_outlined,
                    label: AppStrings.t(context, 'menu_notifications'),
                    onTap: () => navigateTo('/profile/notifications'),
                  ),
                  _DrawerTile(
                    icon: Icons.language_outlined,
                    label: AppStrings.t(context, 'menu_language'),
                    onTap: () => navigateTo('/profile/language'),
                  ),
                  _DrawerTile(
                    icon: Icons.dark_mode_outlined,
                    label: AppStrings.t(context, 'menu_dark_mode'),
                    onTap: () => navigateTo('/profile/theme'),
                  ),
                  const Divider(height: 20),
                  _DrawerTile(
                    icon: Icons.description_outlined,
                    label: AppStrings.t(context, 'menu_terms'),
                    onTap: () => navigateTo('/profile/terms'),
                  ),
                  _DrawerTile(
                    icon: Icons.privacy_tip_outlined,
                    label: AppStrings.t(context, 'menu_privacy'),
                    onTap: () => navigateTo('/profile/privacy'),
                  ),
                  _DrawerTile(
                    icon: Icons.support_agent_outlined,
                    label: AppStrings.t(context, 'menu_help'),
                    onTap: () => navigateTo('/profile/support'),
                  ),
                  _DrawerTile(
                    icon: Icons.mail_outline,
                    label: AppStrings.t(context, 'menu_contact'),
                    onTap: () => navigateTo('/profile/contact'),
                  ),
                  _DrawerTile(
                    icon: Icons.star_outline,
                    label: AppStrings.t(context, 'menu_rate'),
                    onTap: () => navigateTo('/profile/rate'),
                  ),
                  const Divider(height: 20),
                  _DrawerTile(
                    icon: Icons.logout,
                    label: AppStrings.t(context, 'menu_logout'),
                    color: theme.colorScheme.error,
                    onTap: () async {
                      Navigator.of(context).pop();
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: Text(AppStrings.t(dialogContext, 'logout_confirm_title')),
                          content: Text(AppStrings.t(dialogContext, 'logout_confirm_message')),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(dialogContext).pop(false),
                              child: Text(AppStrings.t(dialogContext, 'no')),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(dialogContext).pop(true),
                              child: Text(AppStrings.t(dialogContext, 'yes')),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true && context.mounted) {
                        await context.read<AuthProvider>().logout();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tileColor = color ?? Theme.of(context).colorScheme.onSurface;
    return ListTile(
      leading: Icon(icon, color: tileColor),
      title: Text(label, style: TextStyle(color: tileColor, fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }
}
