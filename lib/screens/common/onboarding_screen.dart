import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_colors.dart';
import '../../widgets/custom_button.dart';

/// Screen representing application feature walkthrough page slider.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<OnboardingStep> _steps = [
    OnboardingStep(
      title: 'Verified Urban Properties',
      description: 'Explore directly with verified owners, zero brokerage, complete transparency.',
      icon: Icons.verified_user_rounded,
    ),
    OnboardingStep(
      title: 'AI Smart Suggestions',
      description: 'Find optimal rentals in Dhaka matched to your budget parameters utilizing Gemini.',
      icon: Icons.psychology_outlined,
    ),
    OnboardingStep(
      title: 'Transparent Transactions',
      description: 'Register offers, sign contracts, and pay securely within one portal.',
      icon: Icons.payments_outlined,
    ),
  ];

  void _onNext() {
    if (_currentIndex < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/tenant-home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (idx) => setState(() => _currentIndex = idx),
                itemCount: _steps.length,
                itemBuilder: (context, idx) {
                  final step = _steps[idx];
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(step.icon, size: 96, color: const Color(0xff1E40AF)),
                        const SizedBox(height: 48),
                        Text(
                          step.title,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colors.textPrimary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          step.description,
                          style: TextStyle(fontSize: 15, color: colors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_steps.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentIndex == index ? const Color(0xffF59E0B) : colors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: CustomButton(
                text: _currentIndex == _steps.length - 1 ? 'Start Exploring' : 'Continue',
                onPressed: _onNext,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingStep {
  final String title;
  final String description;
  final IconData icon;

  OnboardingStep({
    required this.title,
    required this.description,
    required this.icon,
  });
}
