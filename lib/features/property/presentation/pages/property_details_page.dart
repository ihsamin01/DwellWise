import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/verified_badge.dart';
import '../../../../core/routes/app_routes.dart';
import '../providers/property_provider.dart';

class PropertyDetailsPage extends ConsumerWidget {
  const PropertyDetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final property = ref.watch(selectedPropertyProvider);

    if (property == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Property Details')),
        body: const Center(child: Text('No property selected.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Scrollable Content
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Visual Header - Image Carousel Mock
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Architectural Illustration representing the structure
                      Center(
                        child: CustomPaint(
                          size: const Size(200, 160),
                          painter: _ApartmentIllustrationPainter(),
                        ),
                      ),
                      // Verified badge overlay
                      if (property.isVerified)
                        const Positioned(
                          bottom: 20,
                          left: 20,
                          child: VerifiedBadge(size: 14, showText: true),
                        ),
                      // Rating tag
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star, color: AppColors.secondary, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                property.rating.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Detailed Information Container
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Area & Category
                      Text(
                        property.area.toUpperCase(),
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Title
                      Text(
                        property.title,
                        style: AppTextStyles.headlineMedium,
                      ),
                      const SizedBox(height: 12),
                      // Price prominent display
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '৳${property.price.toInt().toString()}',
                                style: AppTextStyles.priceLarge.copyWith(color: AppColors.textPrimary),
                              ),
                              const Text(
                                'Per Month (Transparent Rate)',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.low,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${property.sizeSqFt.toInt()} sq ft',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: AppColors.high),
                      const SizedBox(height: 16),

                      // Bento Grid Box for Facilities
                      Text(
                        'Facilities & Bento Layout',
                        style: AppTextStyles.titleSmall,
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 2.2,
                        children: [
                          _buildFacilityBento(Icons.wifi, 'High Speed Wifi', property.facilities.contains('Wifi')),
                          _buildFacilityBento(Icons.local_parking_rounded, 'Dedicated Parking', property.facilities.contains('Parking')),
                          _buildFacilityBento(Icons.elevator_rounded, '24/7 Lift Access', property.facilities.contains('Lift')),
                          _buildFacilityBento(Icons.power_rounded, 'Generator Backup', property.facilities.contains('Backup')),
                        ],
                      ),
                      const SizedBox(height: 28),
                      const Divider(color: AppColors.high),
                      const SizedBox(height: 16),

                      // Description
                      Text(
                        'About this Dwell',
                        style: AppTextStyles.titleSmall,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        property.description,
                        style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
                      ),
                      const SizedBox(height: 28),
                      const Divider(color: AppColors.high),
                      const SizedBox(height: 16),

                      // Verified Owner details
                      Text(
                        'Property Owner',
                        style: AppTextStyles.titleSmall,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.lowest,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.low, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: AppColors.primary,
                              child: Text(
                                property.ownerImage,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    property.ownerName,
                                    style: AppTextStyles.titleSmall,
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'DwellWise Verified Owner',
                                    style: TextStyle(
                                      color: AppColors.success,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.verified_user,
                                color: AppColors.success,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Sticky Floating Header Buttons
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),

          // 3. Sticky Action Footer
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.lowest,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 15,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    // Call Owner Button
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: const BorderSide(color: AppColors.primary, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          _showCallDialog(context, property.ownerName, property.ownerPhone);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.phone_in_talk, color: AppColors.primary, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Call Owner',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Direct Chat Button
                    Expanded(
                      child: CustomButton(
                        text: 'Chat Now',
                        isPrimary: false, // uses secondary #FEA619
                        icon: Icons.chat_bubble_outline_rounded,
                        onPressed: () {
                          // Navigate to Chat Screen
                          Navigator.pushNamed(context, AppRoutes.directChat);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityBento(IconData icon, String title, bool isAvailable) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isAvailable ? AppColors.lowest : AppColors.high.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAvailable ? AppColors.primary.withOpacity(0.15) : AppColors.high,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isAvailable ? AppColors.primary.withOpacity(0.08) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isAvailable ? AppColors.primary : AppColors.textLight,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isAvailable ? AppColors.textPrimary : AppColors.textLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCallDialog(BuildContext context, String ownerName, String phone) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.lowest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Call $ownerName', style: AppTextStyles.titleMedium),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.phone_forwarded_rounded, color: AppColors.secondary, size: 48),
              const SizedBox(height: 16),
              Text(
                phone,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tell them you found their listing on DwellWise.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Dial'),
            ),
          ],
        );
      },
    );
  }
}

// Vector painted illustration representing an apartment block
class _ApartmentIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..style = PaintingStyle.fill;

    // Background circle glow
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 60, paint);

    // Apartment block shape
    paint.color = Colors.white.withOpacity(0.25);
    final block = Rect.fromLTWH(size.width * 0.35, size.height * 0.15, size.width * 0.3, size.height * 0.7);
    canvas.drawRRect(RRect.fromRectAndRadius(block, const Radius.circular(8)), paint);

    // Windows
    paint.color = AppColors.secondary.withOpacity(0.4);
    for (int y = 0; y < 4; y++) {
      final windowY = size.height * 0.22 + (y * (size.height * 0.15));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.4, windowY, size.width * 0.08, size.height * 0.08),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.52, windowY, size.width * 0.08, size.height * 0.08),
          const Radius.circular(2),
        ),
        paint,
      );
    }

    // Trees on side
    paint.color = AppColors.success.withOpacity(0.25);
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.75), 16, paint);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.75), 18, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
