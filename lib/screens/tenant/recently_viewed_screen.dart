import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_colors.dart';
import '../../providers/property_provider.dart';
import '../../providers/saved_properties_provider.dart';
import '../../providers/recently_viewed_provider.dart';
import '../../models/property_model.dart';
import '../../widgets/property_card.dart';

/// Screen listing every property the tenant has recently viewed, in order
/// (most recent first), using the same summary card style as the home feed.
class TenantRecentlyViewedScreen extends StatelessWidget {
  const TenantRecentlyViewedScreen({Key? key}) : super(key: key);

  void _handlePropertyTap(BuildContext context, PropertyModel property) {
    context.read<RecentlyViewedProvider>().addProperty(property.id);
    context.push('/property/${property.id}');
  }

  void _handleSaveToggle(BuildContext context, SavedPropertiesProvider savedProvider, PropertyModel property) {
    final isSaved = savedProvider.isSaved(property.id);
    savedProvider.toggleSave(property.id);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isSaved ? 'Removed from favorites' : 'Added to favorites'),
        backgroundColor: isSaved ? const Color(0xff6B7280) : const Color(0xff10B981),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final propertyProvider = context.watch<PropertyProvider>();
    final savedProvider = context.watch<SavedPropertiesProvider>();
    final recentlyViewedProvider = context.watch<RecentlyViewedProvider>();

    final allProperties = propertyProvider.lookupPool;
    final recentlyViewedIds = recentlyViewedProvider.recentlyViewedIds;

    // Map viewed IDs to actual properties, skipping any that no longer exist.
    final recentlyViewedList = recentlyViewedIds
        .map((id) {
          final matches = allProperties.where((p) => p.id == id);
          return matches.isEmpty ? null : matches.first;
        })
        .whereType<PropertyModel>()
        .toList();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(
              bottom: BorderSide(color: colors.border, width: 1.0),
            ),
          ),
          child: AppBar(
            backgroundColor: colors.surface,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: colors.primary, size: 24),
              onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
            ),
            title: Text(
              'Recently Viewed',
              style: TextStyle(
                color: colors.primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: recentlyViewedList.isEmpty
          ? _buildEmptyState(context, colors)
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 24.0),
              itemCount: recentlyViewedList.length,
              itemBuilder: (context, index) {
                final property = recentlyViewedList[index];
                final isSaved = savedProvider.isSaved(property.id);

                return PropertyCard(
                  property: property,
                  showDetails: true,
                  isSaved: isSaved,
                  onTap: () => _handlePropertyTap(context, property),
                  onSaveTap: () => _handleSaveToggle(context, savedProvider, property),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 60,
              color: colors.border,
            ),
            const SizedBox(height: 16),
            Text(
              'No recently viewed properties',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Properties you open will appear here',
              style: TextStyle(
                fontSize: 14,
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => context.go('/home'),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: const Color(0xffF59E0B),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Explore Properties',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
