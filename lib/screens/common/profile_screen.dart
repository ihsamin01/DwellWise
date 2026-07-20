import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_colors.dart';
import '../../config/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';

/// Profile hub: a scrollable menu of account actions, matching the app's
/// list-style layout. Each tile routes to a fully functional sub-screen.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.userModel;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(AppStrings.t(context, 'profile')),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _ProfileHeader(user: user, colors: colors),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            child: Column(
              children: [
          _MenuTile(
            colors: colors,
            icon: Icons.verified_user_outlined,
            title: AppStrings.t(context, 'p_acc_verif'),
            subtitle: AppStrings.t(context, 'p_acc_verif_sub'),
            onTap: () => context.push('/profile/verification'),
          ),
          _MenuTile(
            colors: colors,
            icon: Icons.add_home_outlined,
            title: AppStrings.t(context, 'p_add_property'),
            subtitle: AppStrings.t(context, 'p_add_property_sub'),
            onTap: () => context.push('/profile/add-property'),
          ),
          _MenuTile(
            colors: colors,
            icon: Icons.apartment_outlined,
            title: AppStrings.t(context, 'p_my_properties'),
            subtitle: AppStrings.t(context, 'p_my_properties_sub'),
            onTap: () => context.push('/profile/my-properties'),
          ),
          _MenuTile(
            colors: colors,
            icon: Icons.receipt_long_outlined,
            title: AppStrings.t(context, 'p_purchase_history'),
            subtitle: AppStrings.t(context, 'p_purchase_history_sub'),
            onTap: () => context.push('/profile/purchase-history'),
          ),
          _MenuTile(
            colors: colors,
            icon: Icons.edit_outlined,
            title: AppStrings.t(context, 'p_edit_profile'),
            subtitle: AppStrings.t(context, 'p_edit_profile_sub'),
            onTap: () => context.push('/profile/edit'),
          ),
          _MenuTile(
            colors: colors,
            icon: Icons.lock_outline,
            title: AppStrings.t(context, 'p_change_password'),
            subtitle: AppStrings.t(context, 'p_change_password_sub'),
            onTap: () => context.push('/profile/change-password'),
          ),
          _MenuTile(
            colors: colors,
            icon: Icons.logout,
            title: AppStrings.t(context, 'p_logout'),
            subtitle: AppStrings.t(context, 'p_logout_sub'),
            isDestructive: true,
            onTap: () => _confirmLogout(context),
          ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.t(dialogContext, 'logout_confirm_title')),
        content: Text(AppStrings.t(dialogContext, 'logout_confirm_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(AppStrings.t(dialogContext, 'cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xffDC2626)),
            child: Text(AppStrings.t(dialogContext, 'p_logout')),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      context.read<LocaleProvider>().reset();
      await context.read<AuthProvider>().logout();
      if (context.mounted) context.go('/login');
    }
  }
}

/// Avatar + name + phone card with the account verification status chip.
class _ProfileHeader extends StatelessWidget {
  final UserModel? user;
  final AppColors colors;

  const _ProfileHeader({required this.user, required this.colors});

  @override
  Widget build(BuildContext context) {
    const gradientTop = Color(0xff1E40AF);
    const gradientBottom = Color(0xff1E3A8A);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 26),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [gradientTop, gradientBottom],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 46,
                  backgroundColor: Colors.white,
                  backgroundImage:
                      user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
                  child: user?.avatarUrl == null
                      ? const Icon(Icons.person, size: 52, color: gradientTop)
                      : null,
                ),
              ),
              if (user?.isVerified ?? false)
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.verified, color: Color(0xff10B981), size: 24),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  user?.name ?? AppStrings.t(context, 'guest_user'),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              if (user?.isVerified ?? false) ...[
                const SizedBox(width: 6),
                const Icon(Icons.verified, color: Colors.white, size: 20),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            user?.phoneNumber ?? user?.email ?? '',
            style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.85)),
          ),
          const SizedBox(height: 12),
          _VerificationChip(status: user?.verificationStatus ?? VerificationStatus.unverified),
        ],
      ),
    );
  }
}

/// Small pill reflecting the verification lifecycle under the name.
class _VerificationChip extends StatelessWidget {
  final VerificationStatus status;
  const _VerificationChip({required this.status});

  @override
  Widget build(BuildContext context) {
    late final Color color;
    late final IconData icon;
    late final String label;
    switch (status) {
      case VerificationStatus.verified:
        color = const Color(0xff10B981);
        icon = Icons.verified;
        label = AppStrings.t(context, 'verif_verified');
        break;
      case VerificationStatus.pending:
        color = const Color(0xffF59E0B);
        icon = Icons.hourglass_top;
        label = AppStrings.t(context, 'verif_pending');
        break;
      case VerificationStatus.unverified:
        color = const Color(0xff6B7280);
        icon = Icons.gpp_maybe_outlined;
        label = AppStrings.t(context, 'verif_none');
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}

/// Reusable rounded menu row with a tinted leading icon and chevron.
class _MenuTile extends StatelessWidget {
  final AppColors colors;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuTile({
    required this.colors,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isDestructive ? const Color(0xffDC2626) : colors.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border.withOpacity(0.6)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accent, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDestructive ? accent : colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 13, color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: colors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
