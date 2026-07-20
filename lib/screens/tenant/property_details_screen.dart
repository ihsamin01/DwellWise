import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/app_colors.dart';
import '../../providers/property_provider.dart';
import '../../providers/saved_properties_provider.dart';
import '../../providers/chat_provider.dart';
import '../../models/property_model.dart';
import '../../data/owner_directory.dart';

/// Detailed view of a rental property.
class TenantPropertyDetailsScreen extends StatefulWidget {
  final String propertyId;

  const TenantPropertyDetailsScreen({
    Key? key,
    required this.propertyId,
  }) : super(key: key);

  @override
  State<TenantPropertyDetailsScreen> createState() => _TenantPropertyDetailsScreenState();
}

class _TenantPropertyDetailsScreenState extends State<TenantPropertyDetailsScreen> {
  bool _isDescriptionExpanded = false;

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

    final allProperties = propertyProvider.lookupPool;

    // Find matching property model
    final property = allProperties.firstWhere(
      (p) => p.id == widget.propertyId,
      orElse: () => PropertyModel(
        id: widget.propertyId,
        title: 'Serene Sky Terrace',
        description: 'Experience luxury living in the heart of Gulshan. This semi-furnished apartment offers north-facing windows providing exceptional natural light. Features include a modern modular kitchen, dedicated servant\'s quarters, and high-quality fittings throughout. Within walking distance to top-tier cafes and the diplomatic zone.',
        price: 85000,
        area: 'Bashundhara R/A',
        address: 'Bashundhara R/A, Dhaka',
        latitude: 23.8223,
        longitude: 90.4272,
        beds: 3,
        baths: 2,
        sizeSqFt: 1850,
        imageUrls: ['https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format&fit=crop&w=600&q=80'],
        isVerified: true,
        ownerId: 'o3',
        facilities: ['Wifi', 'Parking', 'Gym', 'Security'],
        createdAt: DateTime.now(),
      ),
    );

    final isSaved = savedProvider.isSaved(property.id);
    final owner = OwnerDirectory.forId(property.ownerId);

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
              onPressed: () => context.go('/home'),
            ),
            title: Text(
              'DwellWise',
              style: TextStyle(
                color: colors.primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(Icons.share_outlined, color: colors.primary, size: 24),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Link copied to clipboard.')),
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  isSaved ? Icons.favorite : Icons.favorite_border,
                  color: isSaved ? const Color(0xffDC2626) : colors.primary,
                  size: 24,
                ),
                onPressed: () => _handleSaveToggle(context, savedProvider, property),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. IMAGE CAROUSEL SECTION (300px height)
            SizedBox(
              height: 300,
              child: Stack(
                children: [
                  _DetailsCarousel(imageUrls: property.imageUrls),
                  // Verified Badge (top-left)
                  if (property.isVerified)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xff10B981),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.check_circle, color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text(
                              'Verified',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 2. PROPERTY INFO SECTION (white card, no border)
            Container(
              color: colors.surface,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '৳${property.price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'per month',
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    property.propertyType,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    property.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // 3. LOCATION SECTION (white card)
            Container(
              color: colors.surface,
              padding: const EdgeInsets.all(20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on, color: colors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property.address,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${property.area}, Dhaka',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // 4. KEY INFO ROW (white card)
            Container(
              color: colors.surface,
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildKeyInfoItem(colors, Icons.king_bed, '${property.beds} Bed'),
                  _buildKeyInfoItem(colors, Icons.bathtub, '${property.baths} Bath'),
                  _buildKeyInfoItem(colors, Icons.square_foot, '${property.sizeSqFt.toInt()} sqft'),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // 5. KEY FACILITIES SECTION (white card)
            Container(
              color: colors.surface,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Key Facilities',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridItemFacilities(facilities: property.facilities),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // 6. ABOUT PROPERTY SECTION (white card)
            Container(
              color: colors.surface,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About this property',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    property.description,
                    maxLines: _isDescriptionExpanded ? null : 4,
                    overflow: _isDescriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isDescriptionExpanded = !_isDescriptionExpanded;
                      });
                    },
                    child: Text(
                      _isDescriptionExpanded ? 'Read less' : 'Read more',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // 7. LOCATION MAP SECTION (white card)
            Container(
              color: colors.surface,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Opening Google Maps preview.')),
                          );
                        },
                        child: Text(
                          'Open Maps',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: colors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Map placeholder
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: colors.placeholder,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Map vector lines look design
                        CustomPaint(
                          size: const Size(double.infinity, 200),
                          painter: _MapPainter(lineColor: colors.border),
                        ),
                        // Green Pin indicator
                        const Icon(
                          Icons.location_pin,
                          color: Color(0xff10B981), // Success green pin
                          size: 40,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // 8. PROPERTY OWNER SECTION (white card with border left)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 0),
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(
                  left: BorderSide(color: colors.primary, width: 4.0),
                ),
              ),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PROPERTY OWNER',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Owner Photo circle
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.primaryTint,
                        ),
                        child: Icon(Icons.person, color: colors.primary, size: 28),
                      ),
                      const SizedBox(width: 12),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  owner.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                if (owner.isVerified) ...const [
                                  SizedBox(width: 6),
                                  Icon(Icons.verified, color: Color(0xff10B981), size: 14),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                ..._buildStarIcons(owner.rating),
                                const SizedBox(width: 6),
                                Text(
                                  '${owner.rating.toStringAsFixed(1)} (${owner.reviewCount} reviews)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // 9. CONTACT SECTION (white card buttons)
            Container(
              color: colors.surface,
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  // Message Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        final chatId = context
                            .read<ChatProvider>()
                            .startConversationWithOwner(
                              ownerId: property.ownerId,
                              ownerName: owner.name,
                            );
                        context.push('/chat/$chatId');
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xff1F2937), // Dark Gray
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: colors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.chat_bubble_outline, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Message',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Contact Owner Phone Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Calling Owner: ${owner.phone}')),
                        );
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xffF59E0B), // CTA Orange
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.phone_outlined, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Contact Owner',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100), // bottom clearance padding
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStarIcons(double rating) {
    return List.generate(5, (index) {
      final threshold = index + 1;
      IconData icon;
      if (rating >= threshold) {
        icon = Icons.star;
      } else if (rating >= threshold - 0.5) {
        icon = Icons.star_half;
      } else {
        icon = Icons.star_border;
      }
      return Icon(icon, color: Colors.amber, size: 14);
    });
  }

  Widget _buildKeyInfoItem(AppColors colors, IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: colors.primary, size: 24),
        const SizedBox(height: 6),
        Text(
          text,
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _DetailsCarousel extends StatefulWidget {
  final List<String> imageUrls;
  const _DetailsCarousel({Key? key, required this.imageUrls}) : super(key: key);

  @override
  State<_DetailsCarousel> createState() => _DetailsCarouselState();
}

class _DetailsCarouselState extends State<_DetailsCarousel> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.imageUrls.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (_pageController.hasClients) {
          final next = (_currentIndex + 1) % widget.imageUrls.length;
          _pageController.animateToPage(
            next,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final images = widget.imageUrls.isNotEmpty
        ? widget.imageUrls
        : ['https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format&fit=crop&w=600&q=80'];

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: images.length,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: images[index],
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: colors.placeholder),
              errorWidget: (context, url, err) => const Icon(Icons.error),
            );
          },
        ),
        if (images.length > 1)
          Positioned(
            bottom: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (index) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == index
                        ? const Color(0xffF59E0B)
                        : Colors.white.withOpacity(0.5),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}

class GridItemFacilities extends StatelessWidget {
  final List<String> facilities;

  const GridItemFacilities({
    Key? key,
    required this.facilities,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    // Standard list to draw grid items
    final list = facilities.isEmpty ? ['WiFi', 'Parking', 'Gym', 'Security'] : facilities;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 3.5,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final fac = list[index];
        IconData facIcon = Icons.star;
        if (fac.toLowerCase() == 'wifi') facIcon = Icons.wifi;
        if (fac.toLowerCase() == 'parking') facIcon = Icons.local_parking;
        if (fac.toLowerCase() == 'gym') facIcon = Icons.fitness_center;
        if (fac.toLowerCase() == 'lift') facIcon = Icons.elevator;
        if (fac.toLowerCase() == 'backup') facIcon = Icons.power;
        if (fac.toLowerCase() == 'security') facIcon = Icons.security;
        if (fac.toLowerCase() == 'gas') facIcon = Icons.local_fire_department;

        return Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.primaryTint,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(facIcon, color: colors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              fac,
              style: TextStyle(
                fontSize: 12,
                color: colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MapPainter extends CustomPainter {
  final Color lineColor;

  _MapPainter({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw some simple placeholder map road lines
    canvas.drawLine(Offset(0, size.height * 0.3), Offset(size.width, size.height * 0.3), paint);
    canvas.drawLine(Offset(0, size.height * 0.7), Offset(size.width, size.height * 0.7), paint);
    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.3, size.height), paint);
    canvas.drawLine(Offset(size.width * 0.7, 0), Offset(size.width * 0.7, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) => oldDelegate.lineColor != lineColor;
}
