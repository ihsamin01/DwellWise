import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../widgets/step_indicator.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<OnboardingStepData> _steps = [
    OnboardingStepData(
      title: 'Verified Properties',
      description: 'Explore verified, transparent residential and commercial spaces across Dhaka.',
      type: BangladeshArchitecturalType.parliament,
      badgeText: '100% Verified',
    ),
    OnboardingStepData(
      title: 'Transparent Pricing',
      description: 'Zero hidden fees. Connect directly with owners and lock down transparent rates.',
      type: BangladeshArchitecturalType.lalbagh,
      badgeText: 'Direct Deal',
    ),
    OnboardingStepData(
      title: 'Smart Urban Living',
      description: 'Find your next dwell with Bento-grid facilities checks and price-pinned map searches.',
      type: BangladeshArchitecturalType.skyline,
      badgeText: 'Bento Maps',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (_currentIndex < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Architectural Background Canvas
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: _steps.length,
            itemBuilder: (context, index) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  // Animated gradient backdrop
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: index == 0
                            ? [const Color(0xff00423D), AppColors.primary]
                            : index == 1
                                ? [const Color(0xff003B4C), const Color(0xff00526B)]
                                : [const Color(0xff122A44), const Color(0xff1F4068)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Premium Custom Vector Paintings representing Bangladesh Architecture
                  Positioned(
                    bottom: 250,
                    left: 20,
                    right: 20,
                    height: 280,
                    child: HeroIllustration(type: _steps[index].type),
                  ),
                ],
              );
            },
          ),

          // Glassmorphic Card Panel Overlay (lower half)
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.24),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Verified Badge Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: AppColors.secondary.withOpacity(0.4),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.verified_user,
                              size: 14,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _steps[_currentIndex].badgeText,
                              style: const TextStyle(
                                color: AppColors.secondary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Title Text
                      Text(
                        _steps[_currentIndex].title,
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      // Description Text
                      Text(
                        _steps[_currentIndex].description,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),
                      // Step dot indicators
                      StepIndicator(
                        count: _steps.length,
                        currentIndex: _currentIndex,
                      ),
                      const SizedBox(height: 28),
                      // Next/Start Button
                      CustomButton(
                        text: _currentIndex == _steps.length - 1 ? 'Get Started' : 'Next Step',
                        onPressed: _onNextPressed,
                        isPrimary: false, // uses secondary #FEA619
                        icon: Icons.arrow_forward_rounded,
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
}

enum BangladeshArchitecturalType { parliament, lalbagh, skyline }

class OnboardingStepData {
  final String title;
  final String description;
  final BangladeshArchitecturalType type;
  final String badgeText;

  OnboardingStepData({
    required this.title,
    required this.description,
    required this.type,
    required this.badgeText,
  });
}

class HeroIllustration extends StatelessWidget {
  final BangladeshArchitecturalType type;

  const HeroIllustration({Key? key, required this.type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ArchitecturePainter(type: type),
    );
  }
}

class _ArchitecturePainter extends CustomPainter {
  final BangladeshArchitecturalType type;

  _ArchitecturePainter({required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final accentPaint = Paint()
      ..color = AppColors.secondary.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    if (type == BangladeshArchitecturalType.parliament) {
      // Draw Jatiyo Sangshad Bhaban (National Parliament House of Bangladesh)
      // Background reflection/glow
      paint.color = Colors.white.withOpacity(0.08);
      canvas.drawCircle(Offset(size.width / 2, size.height * 0.6), 80, paint);

      // Central Block
      paint.color = Colors.white.withOpacity(0.25);
      final centerBlock = Rect.fromLTWH(size.width * 0.35, size.height * 0.4, size.width * 0.3, size.height * 0.4);
      canvas.drawRRect(RRect.fromRectAndRadius(centerBlock, const Radius.circular(8)), paint);

      // Left Cylindrical Wing
      final leftWing = Rect.fromLTWH(size.width * 0.22, size.height * 0.45, size.width * 0.15, size.height * 0.35);
      canvas.drawRRect(RRect.fromRectAndRadius(leftWing, const Radius.circular(6)), paint);

      // Right Cylindrical Wing
      final rightWing = Rect.fromLTWH(size.width * 0.63, size.height * 0.45, size.width * 0.15, size.height * 0.35);
      canvas.drawRRect(RRect.fromRectAndRadius(rightWing, const Radius.circular(6)), paint);

      // Geometric Cuts (The signature triangles and circles of Sher-e-Bangla Nagar)
      // Center circle cut out
      paint.color = Colors.black.withOpacity(0.25);
      canvas.drawCircle(Offset(size.width / 2, size.height * 0.52), size.width * 0.05, paint);

      // Left Triangle Cut out
      paint.color = Colors.black.withOpacity(0.2);
      final pathLeft = Path()
        ..moveTo(size.width * 0.29, size.height * 0.52)
        ..lineTo(size.width * 0.24, size.height * 0.65)
        ..lineTo(size.width * 0.34, size.height * 0.65)
        ..close();
      canvas.drawPath(pathLeft, paint);

      // Right Triangle Cut out
      final pathRight = Path()
        ..moveTo(size.width * 0.71, size.height * 0.52)
        ..lineTo(size.width * 0.66, size.height * 0.65)
        ..lineTo(size.width * 0.76, size.height * 0.65)
        ..close();
      canvas.drawPath(pathRight, paint);

      // Highlight point (golden sun representing rising independence)
      canvas.drawCircle(Offset(size.width / 2, size.height * 0.3), 12, accentPaint);
      
    } else if (type == BangladeshArchitecturalType.lalbagh) {
      // Draw Lalbagh Fort
      // Base platform
      paint.color = Colors.white.withOpacity(0.15);
      final base = Rect.fromLTWH(size.width * 0.1, size.height * 0.7, size.width * 0.8, size.height * 0.1);
      canvas.drawRect(base, paint);

      // Main Arch structure
      paint.color = Colors.white.withOpacity(0.25);
      final fort = Rect.fromLTWH(size.width * 0.25, size.height * 0.42, size.width * 0.5, size.height * 0.28);
      canvas.drawRRect(RRect.fromRectAndCorners(fort, topLeft: const Radius.circular(12), topRight: const Radius.circular(12)), paint);

      // Dome
      paint.color = Colors.white.withOpacity(0.35);
      final domePath = Path()
        ..moveTo(size.width * 0.38, size.height * 0.42)
        ..quadraticBezierTo(size.width * 0.5, size.height * 0.25, size.width * 0.62, size.height * 0.42)
        ..close();
      canvas.drawPath(domePath, paint);

      // Minarets
      paint.color = Colors.white.withOpacity(0.3);
      canvas.drawRect(Rect.fromLTWH(size.width * 0.22, size.height * 0.32, size.width * 0.05, size.height * 0.38), paint);
      canvas.drawRect(Rect.fromLTWH(size.width * 0.73, size.height * 0.32, size.width * 0.05, size.height * 0.38), paint);
      // Minaret caps
      canvas.drawCircle(Offset(size.width * 0.245, size.height * 0.32), 6, accentPaint);
      canvas.drawCircle(Offset(size.width * 0.755, size.height * 0.32), 6, accentPaint);

      // Arch door cut out
      paint.color = Colors.black.withOpacity(0.2);
      final doorPath = Path()
        ..moveTo(size.width * 0.44, size.height * 0.7)
        ..lineTo(size.width * 0.44, size.height * 0.54)
        ..quadraticBezierTo(size.width * 0.5, size.height * 0.47, size.width * 0.56, size.height * 0.54)
        ..lineTo(size.width * 0.56, size.height * 0.7)
        ..close();
      canvas.drawPath(doorPath, paint);
      
    } else {
      // Draw Modern Dhaka Skyline (Gulshan / Hatirjheel) with water reflection
      // Skyline silhouette
      paint.color = Colors.white.withOpacity(0.12);
      canvas.drawRect(Rect.fromLTWH(size.width * 0.15, size.height * 0.35, size.width * 0.12, size.height * 0.35), paint);
      paint.color = Colors.white.withOpacity(0.2);
      canvas.drawRect(Rect.fromLTWH(size.width * 0.3, size.height * 0.22, size.width * 0.14, size.height * 0.48), paint);
      paint.color = Colors.white.withOpacity(0.15);
      canvas.drawRect(Rect.fromLTWH(size.width * 0.48, size.height * 0.3, size.width * 0.16, size.height * 0.4), paint);
      paint.color = Colors.white.withOpacity(0.25);
      canvas.drawRect(Rect.fromLTWH(size.width * 0.68, size.height * 0.18, size.width * 0.15, size.height * 0.52), paint);

      // Antennas
      canvas.drawLine(Offset(size.width * 0.37, size.height * 0.22), Offset(size.width * 0.37, size.height * 0.12), linePaint);
      canvas.drawLine(Offset(size.width * 0.75, size.height * 0.18), Offset(size.width * 0.75, size.height * 0.08), linePaint);
      canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.08), 4, accentPaint);

      // Hatirjheel Bridge arch line overlay
      paint.color = Colors.transparent;
      final bridgePath = Path()
        ..moveTo(size.width * 0.05, size.height * 0.65)
        ..quadraticBezierTo(size.width * 0.5, size.height * 0.45, size.width * 0.95, size.height * 0.65);
      canvas.drawPath(bridgePath, linePaint);

      // Water plane
      paint.color = Colors.white.withOpacity(0.08);
      canvas.drawRect(Rect.fromLTWH(0, size.height * 0.7, size.width, size.height * 0.15), paint);
      // Ripples
      canvas.drawLine(Offset(size.width * 0.2, size.height * 0.74), Offset(size.width * 0.4, size.height * 0.74), linePaint);
      canvas.drawLine(Offset(size.width * 0.5, size.height * 0.78), Offset(size.width * 0.8, size.height * 0.78), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
