import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/property_provider.dart';
import '../../models/property_model.dart';
import '../../widgets/bottom_navigation.dart';
import '../../widgets/global_app_bar.dart';

/// Seeker Home Screen showing mockup list layout, recent items, and bottom navigation.
class TenantHomeScreen extends StatefulWidget {
  const TenantHomeScreen({Key? key}) : super(key: key);

  @override
  State<TenantHomeScreen> createState() => _TenantHomeScreenState();
}

class _TenantHomeScreenState extends State<TenantHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropertyProvider>().fetchProperties();
    });
  }

  void _toggleFavorite(BuildContext context, PropertyProvider provider, PropertyModel property) {
    final isSaved = provider.isSaved(property.id);
    provider.toggleFavorite(property.id);
    
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isSaved ? 'Removed from favorites' : 'Added to favorites'),
        backgroundColor: isSaved ? const Color(0xff6B7280) : const Color(0xff10B981),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatPriceK(double price) {
    return '৳${(price / 1000).toStringAsFixed(0)}k';
  }

  @override
  Widget build(BuildContext context) {
    final propertyProvider = context.watch<PropertyProvider>();
    final properties = propertyProvider.properties;

    // Filter properties to match the mockup items
    // Banani Block H -> p2
    // Gulshan 2 -> p1
    // Dhanmondi -> p4
    // Serene Sky Terrace -> p3
    final recentlyViewed = properties.where((p) => p.id == 'p2' || p.id == 'p1' || p.id == 'p4').toList();
    final aiRecommended = properties.where((p) => p.id == 'p3').toList();

    return Scaffold(
      backgroundColor: const Color(0xffF9F9FF), // Light off-white background
      appBar: const GlobalAppBar(),
      body: propertyProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xff1E40AF)),
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),

                  // 1. RECENTLY VIEWED SECTION
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recently Viewed',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff1F2937),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/search'),
                          child: const Text(
                            'View All',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xff1E40AF),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Horizontal scroll list of recently viewed cards
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      itemCount: recentlyViewed.length,
                      itemBuilder: (context, index) {
                        final property = recentlyViewed[index];

                        return Container(
                          width: 140,
                          margin: const EdgeInsets.only(right: 16, bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: property.imageUrls.isNotEmpty
                                      ? property.imageUrls[0]
                                      : 'https://placeholder.com/600',
                                  height: 110,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey.shade100,
                                    height: 110,
                                    child: const Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => const Icon(Icons.error),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      property.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xff1F2937),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _formatPriceK(property.price),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff1E40AF),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2. AI RECOMMENDED FOR YOU SECTION
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.auto_awesome, // Sparkle icon matching mockup
                          color: Color(0xff1E40AF),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'AI Recommended for You',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff1F2937),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Recommended Listings List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    itemCount: aiRecommended.isEmpty ? properties.length : aiRecommended.length,
                    itemBuilder: (context, index) {
                      final property = aiRecommended.isEmpty ? properties[index] : aiRecommended[index];
                      final isSaved = propertyProvider.isSaved(property.id);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 24.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Rounded Image Header with Badges
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        topRight: Radius.circular(16),
                                      ),
                                      child: CachedNetworkImage(
                                        imageUrl: property.imageUrls.isNotEmpty
                                            ? property.imageUrls[0]
                                            : 'https://placeholder.com/600',
                                        height: 220,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(
                                          color: Colors.grey.shade200,
                                          height: 220,
                                          child: const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) => const Icon(Icons.error),
                                      ),
                                    ),
                                    // Verified Badge top left (light green bg, green text, green check icon)
                                    if (property.isVerified)
                                      Positioned(
                                        top: 12,
                                        left: 12,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xff10B981).withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: const Color(0xff10B981), width: 1),
                                          ),
                                          child: Row(
                                            children: const [
                                              Icon(Icons.check_circle, color: Color(0xff10B981), size: 14),
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
                                    // Heart Button top right
                                    Positioned(
                                      top: 12,
                                      right: 12,
                                      child: GestureDetector(
                                        onTap: () => _toggleFavorite(context, propertyProvider, property),
                                        child: CircleAvatar(
                                          backgroundColor: Colors.white.withOpacity(0.9),
                                          child: Icon(
                                            isSaved ? Icons.favorite : Icons.favorite_border,
                                            color: isSaved ? const Color(0xffDC2626) : const Color(0xff6B7280),
                                            size: 22,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                // Details Section
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 20.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Title & Price Row
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              property.title,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xff1F2937),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '৳${property.price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xff1E40AF),
                                                ),
                                              ),
                                              const Text(
                                                'per month',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xff6B7280),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),

                                      // Location Row
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on_outlined, size: 14, color: Color(0xff6B7280)),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              property.address,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Color(0xff6B7280),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),

                                      // Specification chips row (Bed, Bath, sqft)
                                      Row(
                                        children: [
                                          _buildSpecChip('${property.beds} Bed'),
                                          const SizedBox(width: 8),
                                          _buildSpecChip('${property.baths} Bath'),
                                          const SizedBox(width: 8),
                                          _buildSpecChip('${property.sizeSqFt.toInt()} sqft'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            
                            // Plus Floating action button positioned in bottom right corner of card
                            Positioned(
                              bottom: 16,
                              right: 16,
                              child: GestureDetector(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Quick application initialized for ${property.title}.')),
                                  );
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xffF59E0B), // CTA Orange
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xffF59E0B).withOpacity(0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 80), // bottom clearance for bottom nav
                ],
              ),
            ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 0),
    );
  }

  Widget _buildSpecChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xff1E40AF).withOpacity(0.06), // light blue bg
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xff1E40AF), // blue text
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}
