import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../services/supabase_service.dart';

/// The person on the other side of a conversation, opened by tapping their
/// photo or name in the chat header.
///
/// Deliberately thin: a photo, a name, an address and a phone number. It
/// is a courtesy card, not an account page, so nothing here can be edited.
class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({
    super.key,
    required this.userId,
    this.fallbackName,
    this.fallbackImage,
  });

  final String userId;

  /// Shown while the fetch is in flight, so the page is never blank —
  /// the chat already knows this much.
  final String? fallbackName;
  final String? fallbackImage;

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await SupabaseService().getPublicProfile(widget.userId);
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _loading = false;
    });
  }

  String? _value(String key) {
    final raw = _profile?[key];
    if (raw is! String) return null;
    final text = raw.trim();
    return text.isEmpty ? null : text;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);

    final name = _value('name') ?? widget.fallbackName ?? 'DwellWise user';
    final photo = _value('avatar_url') ?? widget.fallbackImage;
    final address = _value('address');
    final phone = _value('phone_number');
    final isVerified = _profile?['verification_status'] == 'verified';

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          Center(
            child: CircleAvatar(
              radius: 72,
              backgroundColor: colors.primaryTint,
              backgroundImage:
                  photo == null ? null : NetworkImage(photo),
              child: photo == null
                  ? Icon(Icons.person, size: 72, color: colors.primary)
                  : null,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              if (isVerified) ...[
                const SizedBox(width: 6),
                const Icon(Icons.verified, size: 20, color: Color(0xff10B981)),
              ],
            ],
          ),
          const SizedBox(height: 28),
          if (_loading)
            Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                ),
              ),
            )
          else ...[
            _Field(
              icon: Icons.place_outlined,
              label: 'Address',
              value: address,
              colors: colors,
            ),
            const SizedBox(height: 12),
            _Field(
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: phone,
              colors: colors,
            ),
          ],
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.icon,
    required this.label,
    required this.value,
    required this.colors,
  });

  final IconData icon;
  final String label;
  final String? value;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colors.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: colors.textSecondary),
                ),
                const SizedBox(height: 3),
                Text(
                  // Saying it is not there beats an empty row the reader
                  // has to interpret.
                  value ?? 'Not provided',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: value == null
                        ? colors.textSecondary
                        : colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
