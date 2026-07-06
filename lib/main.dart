import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';

void main() {
  runApp(
    const ProviderScope(
      child: DwellWiseApp(),
    ),
  );
}

class DwellWiseApp extends StatelessWidget {
  const DwellWiseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DwellWise',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Configure navigation routes for clean separation
      initialRoute: AppRoutes.onboarding,
      routes: {
        AppRoutes.onboarding: (context) => const OnboardingPage(),
        AppRoutes.login: (context) => const LoginPage(),
        AppRoutes.dashboard: (context) => const DashboardPage(),
        AppRoutes.searchFilters: (context) => const SearchFilterPage(),
        AppRoutes.propertyDetails: (context) => const PropertyDetailsPage(),
        AppRoutes.directChat: (context) => const DirectChatPage(),
      },
    );
  }
}
