import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/property_model.dart';

/// Formats an integer amount with thousands separators, e.g. 85000 -> "85,000".
String formatWithCommas(num value) {
  return value.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
}

/// Reusable Property Card widget used across Home, Search, and Saved screens.
///
/// [showDetails] false renders the small horizontal "recently viewed" tile;
/// true renders the full-width summary card (image, title, price, location,
/// and spec chips). Full listing information and contact actions live on the
/// property details screen, reached by tapping the card.
class PropertyCard extends StatelessWidget {
  final PropertyModel property;
  final VoidCallback? onTap;
  final VoidCallback? onSaveTap;
  final bool isSaved;
  final bool showDetails;

  const PropertyCard({
    Key? key,
    required this.property,
    this.onTap,
    this.onSaveTap,
    this.isSaved = false,
    this.showDetails = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!showDetails) {
      // 1. HORIZONTAL RECENTLY VIEWED CARD LAYOUT (120x150px)
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 120,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xffD1D5DB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                child: CachedNetworkImage(
                  imageUrl: property.imageUrls.isNotEmpty
                      ? property.imageUrls[0]
                      : 'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format&fit=crop&w=600&q=80',
                  height: 100,
                  width: 120,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: const Color(0xffE5E7EB)),
                  errorWidget: (context, url, err) => Container(
                    color: const Color(0xffE5E7EB),
                    child: const Icon(Icons.home_work_outlined, color: Color(0xff6B7280)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '৳${(property.price / 1000).toStringAsFixed(0)}k',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff1E40AF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 2. FULL-WIDTH SUMMARY CARD LAYOUT
    // Clean listing preview: image, title, price, location and spec chips.
    // Tapping opens the property details screen for the full information.
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image header with verified badge + save button
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: SizedBox(
                    height: 190,
                    child: _ImageCarousel(imageUrls: property.imageUrls),
                  ),
                ),
                // Verified Badge (top-left)
                if (property.isVerified)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xff10B981),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.check, color: Colors.white, size: 10),
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
                // Save (heart) button (top-right)
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: onSaveTap,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isSaved ? Icons.favorite : Icons.favorite_border,
                        color: isSaved ? const Color(0xffDC2626) : const Color(0xff9CA3AF),
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Summary details block
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + price row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          property.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff1F2937),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '৳${formatWithCommas(property.price)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff1E40AF),
                            ),
                          ),
                          const Text(
                            'per month',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xff6B7280),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Color(0xff6B7280)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xff6B7280),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Spec chips (Bed / Bath / Size)
                  Row(
                    children: [
                      _specChip('${property.beds} Bed'),
                      const SizedBox(width: 8),
                      _specChip('${property.baths} Bath'),
                      const SizedBox(width: 8),
                      _specChip('${formatWithCommas(property.sizeSqFt)} sqft'),
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

  /// Small rounded pill used for the bed / bath / size specs.
  Widget _specChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xffEFF6FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xff1E40AF),
        ),
      ),
    );
  }
}

class _ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  const _ImageCarousel({Key? key, required this.imageUrls}) : super(key: key);

  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
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
              width: double.infinity,
              placeholder: (context, url) => Container(color: const Color(0xffE5E7EB)),
              errorWidget: (context, url, err) => Container(
                color: const Color(0xffE5E7EB),
                child: const Icon(Icons.home_work_outlined, color: Color(0xff6B7280)),
              ),
            );
          },
        ),
        if (images.length > 1)
          Positioned(
            bottom: 12,
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
