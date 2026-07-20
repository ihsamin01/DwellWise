import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Screen imports
import '../screens/common/splash_screen.dart';
import '../screens/common/onboarding_screen.dart';
import '../screens/common/main_tabs_shell.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/registration_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/tenant/listings_screen.dart';
import '../screens/tenant/property_details_screen.dart';
import '../screens/tenant/map_view_screen.dart';
import '../screens/tenant/saved_screen.dart';
import '../screens/tenant/recently_viewed_screen.dart';
import '../screens/tenant/inquiries_screen.dart';
import '../screens/owner/owner_home_screen.dart';
import '../screens/owner/create_listing_screen.dart';
import '../screens/owner/my_listings_screen.dart';
import '../screens/owner/listing_details_screen.dart';
import '../screens/owner/owner_inquiries_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/pending_listings_screen.dart';
import '../screens/admin/reported_listings_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/change_password_screen.dart';
import '../screens/profile/account_security_screen.dart';
import '../screens/profile/notification_settings_screen.dart';
import '../screens/profile/language_settings_screen.dart';
import '../screens/profile/theme_settings_screen.dart';
import '../screens/profile/terms_conditions_screen.dart';
import '../screens/profile/privacy_policy_screen.dart';
import '../screens/profile/help_support_screen.dart';
import '../screens/profile/contact_us_screen.dart';
import '../screens/profile/rate_app_screen.dart';

/// GoRouter configuration for the DwellWise application.
class AppRoutes {
  AppRoutes._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // Common routes
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const MainTabsShell(initialIndex: 4),
      ),

      // Auth routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegistrationScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) => const OtpScreen(),
      ),

      // Tenant routes
      GoRoute(
        path: '/tenant-home',
        builder: (context, state) => const MainTabsShell(initialIndex: 0),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainTabsShell(initialIndex: 0),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const MainTabsShell(initialIndex: 1),
      ),
      GoRoute(
        path: '/listings',
        builder: (context, state) => const TenantListingsScreen(),
      ),
      GoRoute(
        path: '/property-details/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return TenantPropertyDetailsScreen(propertyId: id);
        },
      ),
      GoRoute(
        path: '/property/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return TenantPropertyDetailsScreen(propertyId: id);
        },
      ),
      GoRoute(
        path: '/map-view',
        builder: (context, state) => const TenantMapViewScreen(),
      ),
      GoRoute(
        path: '/saved-listings',
        builder: (context, state) => const TenantSavedScreen(),
      ),
      GoRoute(
        path: '/saved',
        builder: (context, state) => const MainTabsShell(initialIndex: 2),
      ),
      GoRoute(
        path: '/recently-viewed',
        builder: (context, state) => const TenantRecentlyViewedScreen(),
      ),
      GoRoute(
        path: '/inquiries',
        builder: (context, state) => const TenantInquiriesScreen(),
      ),
      GoRoute(
        path: '/messages',
        builder: (context, state) => const MainTabsShell(initialIndex: 3),
      ),

      // Owner routes
      GoRoute(
        path: '/owner-home',
        builder: (context, state) => const OwnerHomeScreen(),
      ),
      GoRoute(
        path: '/create-listing',
        builder: (context, state) => const OwnerCreateListingScreen(),
      ),
      GoRoute(
        path: '/my-listings',
        builder: (context, state) => const OwnerMyListingsScreen(),
      ),
      GoRoute(
        path: '/owner-listing-details/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return OwnerListingDetailsScreen(propertyId: id);
        },
      ),
      GoRoute(
        path: '/owner-inquiries',
        builder: (context, state) => const OwnerInquiriesScreen(),
      ),

      // Admin routes
      GoRoute(
        path: '/admin-dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/pending-listings',
        builder: (context, state) => const AdminPendingListingsScreen(),
      ),
      GoRoute(
        path: '/reported-listings',
        builder: (context, state) => const AdminReportedListingsScreen(),
      ),

      // Chat route
      GoRoute(
        path: '/chat/:chatId',
        builder: (context, state) {
          final chatId = state.pathParameters['chatId'] ?? '';
          return ChatScreen(chatId: chatId);
        },
      ),

      // Profile menu routes
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/profile/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/profile/security',
        builder: (context, state) => const AccountSecurityScreen(),
      ),
      GoRoute(
        path: '/profile/notifications',
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: '/profile/language',
        builder: (context, state) => const LanguageSettingsScreen(),
      ),
      GoRoute(
        path: '/profile/theme',
        builder: (context, state) => const ThemeSettingsScreen(),
      ),
      GoRoute(
        path: '/profile/terms',
        builder: (context, state) => const TermsConditionsScreen(),
      ),
      GoRoute(
        path: '/profile/privacy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/profile/support',
        builder: (context, state) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: '/profile/contact',
        builder: (context, state) => const ContactUsScreen(),
      ),
      GoRoute(
        path: '/profile/rate',
        builder: (context, state) => const RateAppScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('No route defined for ${state.uri}'),
      ),
    ),
  );
}
