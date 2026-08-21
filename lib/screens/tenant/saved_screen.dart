import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_colors.dart';
import '../../config/app_strings.dart';
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

  @override
  void initState() {
    super.initState();
    // Pull the signed-in user's saved properties from the database, so
    // favorites survive logging out and back in.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<SavedPropertiesProvider>().loadSaved();
    });
  }

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
    final savedProvider = context.watch<SavedPropertiesProvider>();

    // Straight from the provider, which loads them from the database. Filtering
    // the home feed by id used to drop any save whose property was not in the
    // slice the feed happened to hold.
    final savedList = savedProvider.savedProperties;

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
              // This screen is always a tab inside MainTabsShell, so "back"
              // should return to the Home tab, not push a new GoRouter page.
              // MainTabsShell's PopScope handles exactly that on pop.
              onPressed: () => Navigator.maybePop(context),
            ),
            title: Text(
              AppStrings.t(context, 'saved_title'),
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
              AppStrings.t(context, 'saved_empty_title'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.t(context, 'saved_empty_subtitle'),
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
                  color: const Color(0xff1877F2), // CTA Orange
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  AppStrings.t(context, 'saved_explore_cta'),
                  style: const TextStyle(
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
