import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/property_provider.dart';
import '../../models/property_model.dart';
import '../../widgets/bottom_navigation.dart';
import '../../widgets/global_app_bar.dart';

/// Screen listing properties favorited by the tenant.
class TenantSavedScreen extends StatefulWidget {
  const TenantSavedScreen({Key? key}) : super(key: key);

  @override
  State<TenantSavedScreen> createState() => _TenantSavedScreenState();
}

class _TenantSavedScreenState extends State<TenantSavedScreen> {
  // Set to keep track of cards that are currently animating/removing
  final Set<String> _removingIds = {};

  void _onUnsave(BuildContext context, PropertyProvider provider, PropertyModel property) async {
    // Add to removing list to trigger fade & shrink animation locally first
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
      provider.toggleFavorite(property.id);
      setState(() {
        _removingIds.remove(property.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final propertyProvider = context.watch<PropertyProvider>();
    final savedList = propertyProvider.savedProperties;

    return Scaffold(
      backgroundColor: const Color(0xffF3F4F6),
      appBar: const GlobalAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // HEADER SECTION
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Saved Properties',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1F2937),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your favorite listings',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xff6B7280),
                  ),
                ),
              ],
            ),
          ),

          // LIST OR EMPTY STATE
          Expanded(
            child: savedList.isEmpty && _removingIds.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                              : Container(
                                  margin: const EdgeInsets.only(bottom: 20.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xffD1D5DB)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(8),
                                              topRight: Radius.circular(8),
                                            ),
                                            child: CachedNetworkImage(
                                              imageUrl: property.imageUrls.isNotEmpty
                                                  ? property.imageUrls[0]
                                                  : 'https://placeholder.com/600',
                                              height: 200,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) => Container(
                                                color: Colors.grey.shade200,
                                                height: 200,
                                                child: const Center(
                                                  child: CircularProgressIndicator(),
                                                ),
                                              ),
                                              errorWidget: (context, url, error) => const Icon(Icons.error),
                                            ),
                                          ),
                                          // Verified Badge
                                          if (property.isVerified)
                                            Positioned(
                                              top: 12,
                                              left: 12,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.9),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Row(
                                                  children: const [
                                                    Icon(Icons.verified, color: Color(0xff10B981), size: 14),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      'Verified',
                                                      style: TextStyle(
                                                        color: Color(0xff10B981),
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          // Heart button (Filled Red)
                                          Positioned(
                                            top: 12,
                                            right: 12,
                                            child: GestureDetector(
                                              onTap: () => _onUnsave(context, propertyProvider, property),
                                              child: CircleAvatar(
                                                backgroundColor: Colors.white.withOpacity(0.9),
                                                child: const Icon(
                                                  Icons.favorite,
                                                  color: Color(0xffDC2626), // Filled Red
                                                  size: 24,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      // Property details
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              property.title,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xff1F2937),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Text(
                                                  '৳${property.price.toInt()}',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xff1E40AF),
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                const Text(
                                                  'per month',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xff6B7280),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              '${property.beds} Bed  ${property.baths} Bath  ${property.sizeSqFt.toInt()} sqft',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xff6B7280),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(Icons.location_on_outlined, size: 14, color: Color(0xff6B7280)),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    property.address,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Color(0xff6B7280),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            
                                            // View on Map Button
                                            GestureDetector(
                                              onTap: () => context.go('/map-view'),
                                              child: Container(
                                                height: 36,
                                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xff1E40AF),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: const Center(
                                                  widthFactor: 1,
                                                  child: Text(
                                                    'View on Map',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 56), // clearance for bottom navigation
        ],
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 2),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.favorite_border,
              size: 60,
              color: Color(0xffD1D5DB), // Border Gray
            ),
            const SizedBox(height: 16),
            const Text(
              'No saved properties yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xff1F2937),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start exploring and save your favorites',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xff6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => context.go('/search'),
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
