import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../config/app_colors.dart';
import '../../models/property_model.dart';
import '../../providers/property_provider.dart';
import '../../widgets/property_card.dart';

/// Lists the properties the current user has posted for rent, with a quick
/// delete action. New listings from "Add property" land here.
class MyPropertiesScreen extends StatelessWidget {
  const MyPropertiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final listings = context.watch<PropertyProvider>().myListings;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: const Text('My properties')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/profile/add-property'),
        icon: const Icon(Icons.add),
        label: const Text('Add property'),
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
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete listing'),
        content: Text('Remove "${property.title}" from your properties?'),
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
    if (confirmed == true && context.mounted) {
      context.read<PropertyProvider>().removeMyListing(property.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing removed.')),
      );
    }
  }
}

class _MyPropertyCard extends StatelessWidget {
  final PropertyModel property;
  final AppColors colors;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _MyPropertyCard({
    required this.property,
    required this.colors,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
                          property.title,
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
                          property.address,
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
                        '৳${formatWithCommas(property.price)}',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colors.primary),
                      ),
                      Text(' / ${property.priceFor.toLowerCase()}',
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
                      _spec(colors, Icons.bed_outlined, '${property.beds} Bed'),
                      _spec(colors, Icons.bathtub_outlined, '${property.baths} Bath'),
                      _spec(colors, Icons.balcony_outlined, '${property.balcony} Balcony'),
                      if (property.availableFrom.isNotEmpty)
                        _spec(colors, Icons.event_available_outlined,
                            'From ${property.availableFrom}'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
          Text(isVerified ? 'Verified' : 'Pending',
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
            Text('No properties yet',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: colors.textPrimary)),
            const SizedBox(height: 8),
            Text('Post your first property and it will show up here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
