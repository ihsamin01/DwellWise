import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_colors.dart';
import '../../providers/property_provider.dart';
import '../../providers/saved_properties_provider.dart';
import '../../providers/recently_viewed_provider.dart';
import '../../models/property_model.dart';
import '../../widgets/bottom_navigation.dart';
import '../../widgets/property_card.dart';

/// Screen listing properties favorited by the tenant.
class TenantSavedScreen extends StatefulWidget {
  final bool showBottomNavigation;

  const TenantSavedScreen({
    super.key,
    this.showBottomNavigation = true,
  });

  @override
  State<TenantSavedScreen> createState() => _TenantSavedScreenState();
}

class _TenantSavedScreenState extends State<TenantSavedScreen> {
  final Set<String> _removingIds = {};

  void _onUnsave(BuildContext context, SavedPropertiesProvider savedProvider,
      PropertyModel property) async {
    setState(() {
      _removingIds.add(property.id);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Removed from favorites'),
        duration: Duration(seconds: 2),
      ),
    );

    // Wait for the local fade out and slide animation to finish before updating global state
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      savedProvider.unsave(property.id);
      setState(() {
        _removingIds.remove(property.id);
      });
    }
  }

  void _handlePropertyTap(BuildContext context, PropertyModel property) {
    context.read<RecentlyViewedProvider>().addProperty(property.id);
    context.push('/property/${property.id}');
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final propertyProvider = context.watch<PropertyProvider>();
    final savedProvider = context.watch<SavedPropertiesProvider>();

    final allProperties = propertyProvider.lookupPool;
    final savedIds = savedProvider.savedIds;

    // Filter properties list dynamically based on SavedProvider IDs
    final savedList =
        allProperties.where((p) => savedIds.contains(p.id)).toList();

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
            automaticallyImplyLeading: false,
            title: Text(
              'Saved Properties',
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: savedList.isEmpty && _removingIds.isEmpty
                ? _buildEmptyState(context, colors)
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0),
                    itemCount: savedList.length,
                    itemBuilder: (context, index) {
                      final property = savedList[index];
                      final isRemoving = _removingIds.contains(property.id);

                      // Wrap each card in AnimatedOpacity and AnimatedSize for smooth disappearing transition
                      return AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: isRemoving ? 0.0 : 1.0,
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: isRemoving
                              ? const SizedBox.shrink()
                              : PropertyCard(
                                  property: property,
                                  showDetails: true,
                                  isSaved: true,
                                  onTap: () =>
                                      _handlePropertyTap(context, property),
                                  onSaveTap: () => _onUnsave(
                                      context, savedProvider, property),
                                ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 120), // bottom clearance for bottom nav
        ],
      ),
      bottomNavigationBar: widget.showBottomNavigation
          ? const BottomNavigation(currentIndex: 2)
          : null,
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
              Icons.favorite_border,
              size: 60,
              color: colors.border,
            ),
            const SizedBox(height: 16),
            Text(
              'No saved properties yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Start exploring and save your favorites',
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
                  color: const Color(0xffF59E0B), // CTA Orange
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
