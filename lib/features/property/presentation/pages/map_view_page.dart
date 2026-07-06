import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/verified_badge.dart';
import '../../../../core/routes/app_routes.dart';
import '../providers/property_provider.dart';
import '../../data/models/property_model.dart';

class MapViewPage extends ConsumerStatefulWidget {
  const MapViewPage({Key? key}) : super(key: key);

  @override
  ConsumerState<MapViewPage> createState() => _MapViewPageState();
}

class _MapViewPageState extends ConsumerState<MapViewPage> {
  Property? _selectedProperty;

  @override
  Widget build(BuildContext context) {
    final properties = ref.watch(propertiesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Vector Painted Mock Map of Dhaka
          Positioned.fill(
            child: InteractiveViewer(
              maxScale: 3.0,
              minScale: 0.8,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(
                    painter: _DhakaMapPainter(),
                  ),
                  // Render active property price-pins on the coordinate space
                  ...properties.map((property) {
                    final isSelected = _selectedProperty?.id == property.id;
                    // Map lat/long to logical coordinates
                    final offset = _getMapPosition(property.latitude, property.longitude);
                    return Positioned(
                      left: offset.dx - 45,
                      top: offset.dy - 20,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedProperty = property;
                          });
                        },
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 200),
                          scale: isSelected ? 1.15 : 1.0,
                          child: Container(
                            width: 90,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.secondary : AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: (isSelected ? AppColors.secondary : AppColors.primary).withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: isSelected ? AppColors.textPrimary : Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '৳${(property.price / 1000).toStringAsFixed(0)}k',
                                  style: TextStyle(
                                    color: isSelected ? AppColors.textPrimary : Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),

          // 2. Map Floating Overlays (Top search and navigation buttons)
          Positioned(
            top: 16,
            left: 20,
            right: 20,
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.lowest,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_searching_rounded, color: AppColors.primary),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Dhaka Urban Market Map',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Live Pins',
                      style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Smooth Slidable Bottom Preview Sheet (slides up when property is selected)
          if (_selectedProperty != null)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              bottom: 16,
              left: 20,
              right: 20,
              child: Dismissible(
                key: Key(_selectedProperty!.id),
                direction: DismissDirection.down,
                onDismissed: (_) {
                  setState(() {
                    _selectedProperty = null;
                  });
                },
                child: GestureDetector(
                  onTap: () {
                    ref.read(selectedPropertyProvider.notifier).state = _selectedProperty;
                    Navigator.pushNamed(context, AppRoutes.propertyDetails);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.lowest,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(color: AppColors.low, width: 1.5),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Drag handle bar
                        Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppColors.high,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Row(
                          children: [
                            // Visual placeholder representing the architectural listing
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: AppColors.low,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.apartment_rounded,
                                color: AppColors.primary,
                                size: 36,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _selectedProperty!.title,
                                          style: AppTextStyles.titleMedium,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textSecondary),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          _selectedProperty!.area,
                                          style: AppTextStyles.bodySmall,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      if (_selectedProperty!.isVerified) ...[
                                        const VerifiedBadge(size: 11, showText: true),
                                        const SizedBox(width: 8),
                                      ],
                                      Text(
                                        '${_selectedProperty!.beds} BHK',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '৳${_selectedProperty!.price.toInt().toString()}/month',
                                    style: AppTextStyles.priceMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Helper coordinate mapper
  Offset _getMapPosition(double lat, double lng) {
    // Map bounding boxes: Dhaka region (Uttara: top, Dhanmondi: bottom, Banani: center, Gulshan: right)
    // Approximate scaling coordinates to fit screen sizes logically
    const double latMin = 23.73;
    const double latMax = 23.89;
    const double lngMin = 90.35;
    const double lngMax = 90.45;

    // Logical map box sizes
    const double mapWidth = 500;
    const double mapHeight = 800;

    final double x = ((lng - lngMin) / (lngMax - lngMin)) * mapWidth;
    final double y = mapHeight - (((lat - latMin) / (latMax - latMin)) * mapHeight);

    return Offset(x + 50, y + 100);
  }
}

// Custom Painter representing Dhaka Roads, Neighborhoods and Hatirjheel Lake
class _DhakaMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = const Color(0xffEBF3F5);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width * 2, size.height * 2), backgroundPaint);

    final waterPaint = Paint()
      ..color = const Color(0xffC6D9DD)
      ..style = PaintingStyle.fill;

    final primaryRoadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final secondaryRoadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final labelStyle = TextStyle(
      color: AppColors.textSecondary.withOpacity(0.5),
      fontSize: 12,
      fontWeight: FontWeight.bold,
      letterSpacing: 2.0,
    );

    // Draw Lake Hatirjheel (abstract polygon)
    final lakePath = Path()
      ..moveTo(size.width * 0.4, size.height * 0.45)
      ..quadraticBezierTo(size.width * 0.55, size.height * 0.43, size.width * 0.7, size.height * 0.45)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.48, size.width * 0.9, size.height * 0.42)
      ..lineTo(size.width * 0.9, size.height * 0.52)
      ..quadraticBezierTo(size.width * 0.7, size.height * 0.5, size.width * 0.55, size.height * 0.54)
      ..quadraticBezierTo(size.width * 0.45, size.height * 0.52, size.width * 0.4, size.height * 0.45)
      ..close();
    canvas.drawPath(lakePath, waterPaint);

    // Draw Gulshan Lake
    final gulshanLakePath = Path()
      ..moveTo(size.width * 0.7, size.height * 0.2)
      ..lineTo(size.width * 0.68, size.height * 0.42)
      ..lineTo(size.width * 0.73, size.height * 0.42)
      ..lineTo(size.width * 0.76, size.height * 0.2)
      ..close();
    canvas.drawPath(gulshanLakePath, waterPaint);

    // Draw Major Roads (Dhaka Mymensingh Highway, Pragati Sarani, Airport Road)
    // Main vertical highway
    canvas.drawLine(Offset(size.width * 0.35, 0), Offset(size.width * 0.35, size.height), primaryRoadPaint);
    // Gulshan Avenue
    canvas.drawLine(Offset(size.width * 0.65, size.height * 0.15), Offset(size.width * 0.65, size.height * 0.6), primaryRoadPaint);
    // Pragati Sarani
    canvas.drawLine(Offset(size.width * 0.85, 0), Offset(size.width * 0.85, size.height), primaryRoadPaint);
    // Mirpur Road
    canvas.drawLine(Offset(size.width * 0.15, size.height * 0.3), Offset(size.width * 0.15, size.height), primaryRoadPaint);

    // Secondary connecting road grids
    canvas.drawLine(Offset(0, size.height * 0.25), Offset(size.width, size.height * 0.25), secondaryRoadPaint);
    canvas.drawLine(Offset(0, size.height * 0.45), Offset(size.width, size.height * 0.45), secondaryRoadPaint);
    canvas.drawLine(Offset(0, size.height * 0.65), Offset(size.width, size.height * 0.65), secondaryRoadPaint);

    // Render Area labels on the map canvas
    _drawAreaLabel(canvas, 'UTTARA', Offset(size.width * 0.4, size.height * 0.1), labelStyle);
    _drawAreaLabel(canvas, 'BANANI', Offset(size.width * 0.42, size.height * 0.35), labelStyle);
    _drawAreaLabel(canvas, 'GULSHAN', Offset(size.width * 0.72, size.height * 0.32), labelStyle);
    _drawAreaLabel(canvas, 'BARIDHARA', Offset(size.width * 0.78, size.height * 0.18), labelStyle);
    _drawAreaLabel(canvas, 'DHANMONDI', Offset(size.width * 0.12, size.height * 0.75), labelStyle);
  }

  void _drawAreaLabel(Canvas canvas, String label, Offset offset, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: label, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(offset.dx - textPainter.width / 2, offset.dy - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
