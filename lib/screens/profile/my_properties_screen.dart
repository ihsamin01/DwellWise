import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../config/app_colors.dart';
import '../../config/app_strings.dart';
import '../../models/property_model.dart';
import '../../providers/property_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/property_card.dart';

/// Lists the properties the current user has posted for rent, with a quick
/// delete action. New listings from "Add property" land here.
class MyPropertiesScreen extends StatelessWidget {
  const MyPropertiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final listings = context.watch<PropertyProvider>().myListings;
    // These are the current user's own posts, so the owner shown on each card
    // is the signed-in user's profile name and phone number.
    final user = context.watch<UserProvider>().userModel;
    final ownerName = user?.name ?? 'You';
    final ownerPhone = user?.phoneNumber ?? '';

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: Text(AppStrings.t(context, 'p_my_properties'))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/profile/add-property'),
        icon: const Icon(Icons.add),
        label: Text(AppStrings.t(context, 'p_add_property')),
      ),
      body: listings.isEmpty
          ? _EmptyState(colors: colors)
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: listings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final property = listings[index];
                return _MyPropertyCard(
                  property: property,
                  colors: colors,
                  ownerName: ownerName,
                  ownerPhone: ownerPhone,
                  onTap: () => context.push('/property/${property.id}'),
                  onDelete: () => _confirmDelete(context, property),
                );
              },
            ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, PropertyModel property) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final bangla = AppStrings.isBangla(dialogContext);
        final title = property.localizedTitle(bangla);
        return AlertDialog(
          title: Text(AppStrings.t(dialogContext, 'mp_delete_title')),
          content: Text(
              '${AppStrings.t(dialogContext, 'mp_delete_prefix')} "$title" ${AppStrings.t(dialogContext, 'mp_delete_suffix')}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(AppStrings.t(dialogContext, 'cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: const Color(0xffDC2626)),
              child: Text(AppStrings.t(dialogContext, 'delete')),
            ),
          ],
        );
      },
    );
    if (confirmed == true && context.mounted) {
      context.read<PropertyProvider>().removeMyListing(property.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.tr(context, 'mp_removed'))),
      );
    }
  }
}

class _MyPropertyCard extends StatelessWidget {
  final PropertyModel property;
  final AppColors colors;
  final String ownerName;
  final String ownerPhone;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _MyPropertyCard({
    required this.property,
    required this.colors,
    required this.ownerName,
    required this.ownerPhone,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bangla = AppStrings.isBangla(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border.withOpacity(0.6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: SizedBox(
                height: 150,
                width: double.infinity,
                child: property.imageUrls.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: property.imageUrls.first,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: colors.placeholder),
                        errorWidget: (_, __, ___) => Container(
                          color: colors.placeholder,
                          child: Icon(Icons.home_work_outlined, color: colors.textSecondary),
                        ),
                      )
                    : Container(
                        color: colors.placeholder,
                        child: Icon(Icons.home_work_outlined,
                            size: 40, color: colors.textSecondary),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          property.localizedTitle(bangla),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary),
                        ),
                      ),
                      _StatusPill(isVerified: property.isVerified),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 14, color: colors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.localizedAddress(bangla),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13, color: colors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        '৳${AppStrings.digits(context, formatWithCommas(property.price))}',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colors.primary),
                      ),
                      Text(' / ${AppStrings.t(context, 'period_${property.priceFor}')}',
                          style: TextStyle(fontSize: 12, color: colors.textSecondary)),
                      const Spacer(),
                      IconButton(
                        onPressed: onDelete,
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.delete_outline, color: Color(0xffDC2626)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _spec(colors, Icons.bed_outlined,
                          '${AppStrings.digits(context, '${property.beds}')} ${AppStrings.t(context, 'spec_bed')}'),
                      _spec(colors, Icons.bathtub_outlined,
                          '${AppStrings.digits(context, '${property.baths}')} ${AppStrings.t(context, 'spec_bath')}'),
                      _spec(colors, Icons.balcony_outlined,
                          '${AppStrings.digits(context, '${property.balcony}')} ${AppStrings.t(context, 'spec_balcony')}'),
                      if (property.availableFrom.isNotEmpty)
                        _spec(colors, Icons.event_available_outlined,
                            '${AppStrings.t(context, 'spec_from')} ${AppStrings.t(context, 'month_${property.availableFrom}')}'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(height: 1, color: colors.border.withOpacity(0.6)),
                  const SizedBox(height: 12),
                  _ownerRow(context, colors),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Owner (the current user) shown on each listing: name + phone from profile.
  Widget _ownerRow(BuildContext context, AppColors colors) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: colors.primary.withOpacity(0.12),
          child: Icon(Icons.person, size: 20, color: colors.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ownerName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.phone_outlined, size: 13, color: colors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    ownerPhone.isNotEmpty
                        ? AppStrings.digits(context, ownerPhone)
                        : AppStrings.t(context, 'mp_no_phone'),
                    style: TextStyle(fontSize: 12.5, color: colors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            AppStrings.t(context, 'mp_owner_badge'),
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: colors.primary),
          ),
        ),
      ],
    );
  }

  Widget _spec(AppColors colors, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.primaryTint,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.primary),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: colors.primary)),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool isVerified;
  const _StatusPill({required this.isVerified});

  @override
  Widget build(BuildContext context) {
    final color = isVerified ? const Color(0xff10B981) : const Color(0xffF59E0B);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isVerified ? Icons.verified : Icons.hourglass_top, size: 13, color: color),
          const SizedBox(width: 4),
          Text(AppStrings.t(context, isVerified ? 'status_verified' : 'status_pending'),
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppColors colors;
  const _EmptyState({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.apartment_outlined, size: 72, color: colors.textSecondary),
            const SizedBox(height: 16),
            Text(AppStrings.t(context, 'mp_empty_title'),
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: colors.textPrimary)),
            const SizedBox(height: 8),
            Text(AppStrings.t(context, 'mp_empty_desc'),
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
