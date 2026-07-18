import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/property_provider.dart';
import '../../providers/saved_properties_provider.dart';
import '../../models/property_model.dart';

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

    return Scaffold(
      backgroundColor: const Color(0xffF3F4F6),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xffD1D5DB), width: 1.0),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xff1E40AF), size: 24),
              onPressed: () => context.go('/home'),
            ),
            title: const Text(
              'DwellWise',
              style: TextStyle(
                color: Color(0xff1E40AF),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined, color: Color(0xff1E40AF), size: 24),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Link copied to clipboard.')),
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  isSaved ? Icons.favorite : Icons.favorite_border,
                  color: isSaved ? const Color(0xffDC2626) : const Color(0xff1E40AF),
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
              color: Colors.white,
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
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff1E40AF),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'per month',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xff6B7280),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    property.propertyType,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xff6B7280),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    property.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff1F2937),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // 3. LOCATION SECTION (white card)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, color: Color(0xff1E40AF), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property.address,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${property.area}, Dhaka',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xff6B7280),
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
              color: Colors.white,
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildKeyInfoItem(Icons.king_bed, '${property.beds} Bed'),
                  _buildKeyInfoItem(Icons.bathtub, '${property.baths} Bath'),
                  _buildKeyInfoItem(Icons.square_foot, '${property.sizeSqFt.toInt()} sqft'),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // 5. KEY FACILITIES SECTION (white card)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Key Facilities',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff1F2937),
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
              color: Colors.white,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About this property',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    property.description,
                    maxLines: _isDescriptionExpanded ? null : 4,
                    overflow: _isDescriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xff6B7280),
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
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff1E40AF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // 7. LOCATION MAP SECTION (white card)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff1F2937),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Opening Google Maps preview.')),
                          );
                        },
                        child: const Text(
                          'Open Maps',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff1E40AF),
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
                      color: const Color(0xffE5E7EB), // Gray map background
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Map vector lines look design
                        CustomPaint(
                          size: const Size(double.infinity, 200),
                          painter: _MapPainter(),
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
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  left: BorderSide(color: Color(0xff1E40AF), width: 4.0),
                ),
              ),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PROPERTY OWNER',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff6B7280),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Owner Photo circle
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xffEFF6FF),
                        ),
                        child: const Icon(Icons.person, color: Color(0xff1E40AF), size: 28),
                      ),
                      const SizedBox(width: 12),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Text(
                                  'Rashed Ahmed',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff1F2937),
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(Icons.verified, color: Color(0xff10B981), size: 14),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: const [
                                Icon(Icons.star, color: Colors.amber, size: 14),
                                Icon(Icons.star, color: Colors.amber, size: 14),
                                Icon(Icons.star, color: Colors.amber, size: 14),
                                Icon(Icons.star, color: Colors.amber, size: 14),
                                Icon(Icons.star_half, color: Colors.amber, size: 14),
                                SizedBox(width: 6),
                                Text(
                                  '4.5 (24 reviews)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xff6B7280),
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
              color: Colors.white,
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  // Message Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Chat initialized with Rashed Ahmed.')),
                        );
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xff1F2937), // Dark Gray
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xffD1D5DB)),
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
                          const SnackBar(content: Text('Calling Owner: +8801700000000')),
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

  Widget _buildKeyInfoItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xff1E40AF), size: 24),
        const SizedBox(height: 6),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xff1F2937),
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
              placeholder: (context, url) => Container(color: const Color(0xffE5E7EB)),
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
                color: const Color(0xffEFF6FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(facIcon, color: const Color(0xff1E40AF), size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              fac,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xff1F2937),
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
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw some simple placeholder map road lines
    canvas.drawLine(Offset(0, size.height * 0.3), Offset(size.width, size.height * 0.3), paint);
    canvas.drawLine(Offset(0, size.height * 0.7), Offset(size.width, size.height * 0.7), paint);
    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.3, size.height), paint);
    canvas.drawLine(Offset(size.width * 0.7, 0), Offset(size.width * 0.7, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
