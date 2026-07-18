import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Screen imports
import '../screens/common/splash_screen.dart';
import '../screens/common/onboarding_screen.dart';
import '../screens/common/profile_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/registration_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/tenant/home_screen.dart';
import '../screens/tenant/search_screen.dart';
import '../screens/tenant/listings_screen.dart';
import '../screens/tenant/property_details_screen.dart';
import '../screens/tenant/map_view_screen.dart';
import '../screens/tenant/saved_screen.dart';
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
        builder: (context, state) => const ProfileScreen(),
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
        builder: (context, state) => const TenantHomeScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const TenantSearchScreen(),
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
        path: '/map-view',
        builder: (context, state) => const TenantMapViewScreen(),
      ),
      GoRoute(
        path: '/saved-listings',
        builder: (context, state) => const TenantSavedScreen(),
      ),
      GoRoute(
        path: '/inquiries',
        builder: (context, state) => const TenantInquiriesScreen(),
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
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('No route defined for ${state.uri}'),
      ),
    ),
  );
}
