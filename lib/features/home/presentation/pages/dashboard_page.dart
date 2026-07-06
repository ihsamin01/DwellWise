import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../core/widgets/verified_badge.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/routes/app_routes.dart';
import '../widgets/perspective_toggle.dart';
import '../../../../features/property/presentation/providers/property_provider.dart';
import '../../../../features/property/data/models/property_model.dart';

import '../../../../features/property/presentation/pages/map_view_page.dart';
import '../../../../features/property/presentation/pages/create_listing_page.dart';
import '../../../../features/chat/presentation/pages/inquiries_page.dart';
import '../../../../features/chat/presentation/pages/direct_chat_page.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _activeNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Determine the visible body page based on the bottom navigation tab index
    Widget body;
    switch (_activeNavIndex) {
      case 0:
        body = const _HomeDashboardBody();
        break;
      case 1:
        body = const MapViewPage();
        break;
      case 2:
        body = CreateListingPage(
          onSuccess: () {
            setState(() {
              _activeNavIndex = 0; // Redirect back to Home Dashboard on listing success
            });
          },
        );
        break;
      case 3:
        body = const InquiriesPage();
        break;
      case 4:
        body = const DirectChatPage();
        break;
      default:
        body = const _HomeDashboardBody();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: body,
      bottomNavigationBar: DwellWiseBottomNavBar(
        currentIndex: _activeNavIndex,
        onTap: (index) {
          setState(() {
            _activeNavIndex = index;
          });
        },
      ),
    );
  }
}

// Inner body widget representing the main Home Dashboard (Seeker vs Owner view)
class _HomeDashboardBody extends ConsumerWidget {
  const _HomeDashboardBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSeeker = ref.watch(perspectiveProvider);
    final properties = ref.watch(propertiesProvider);

    return SafeArea(
      child: Column(
        children: [
          // Header Bar with Profile & Perspective Switcher
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: const Text(
                        'SA',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Assalamu Alaikum,',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Samin Azhan',
                          style: AppTextStyles.titleMedium,
                        ),
                      ],
                    ),
                  ],
                ),
                // Premium notification icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.lowest,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.low),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    size: 20,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Perspective Switch Toggle Widget
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: PerspectiveToggle(
              isSeeker: isSeeker,
              onChanged: (val) {
                ref.read(perspectiveProvider.notifier).setPerspective(val);
              },
            ),
          ),

          // Sliding Body Content based on Perspective
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isSeeker
                  ? _buildSeekerDashboard(context, properties, ref)
                  : _buildOwnerDashboard(context, properties, ref),
            ),
          ),
        ],
      ),
    );
  }

  // SEEKER VIEW
  Widget _buildSeekerDashboard(BuildContext context, List<Property> properties, WidgetRef ref) {
    final verifiedProperties = properties.where((p) => p.isVerified).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      key: const ValueKey('seeker'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Elegant Banner Card promoting transparency
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xff00423D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verified Rentals Only',
                        style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Direct owner listings, 0% brokerage charges across urban Dhaka.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.security_rounded,
                    size: 32,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.searchFilters);
              },
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.lowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.high, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Search by area (e.g. Gulshan, Banani)',
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Horizontal Carousel - Recently Viewed
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Recently Viewed',
              style: AppTextStyles.titleMedium,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(left: 20, right: 8),
              itemCount: properties.length.clamp(0, 3), // Show first 3
              itemBuilder: (context, index) {
                final property = properties[index];
                return GestureDetector(
                  onTap: () {
                    ref.read(selectedPropertyProvider.notifier).state = property;
                    Navigator.pushNamed(context, AppRoutes.propertyDetails);
                  },
                  child: Container(
                    width: 280,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: AppColors.lowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.low),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.textPrimary.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                          child: Container(
                            width: 100,
                            color: AppColors.low,
                            child: Stack(
                              children: [
                                const Center(
                                  child: Icon(Icons.home_work_rounded, color: AppColors.primary, size: 36),
                                ),
                                if (property.isVerified)
                                  const Positioned(
                                    top: 8,
                                    left: 8,
                                    child: VerifiedBadge(size: 12, showText: false),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  property.title,
                                  style: AppTextStyles.titleSmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textSecondary),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        property.area.split(',')[0],
                                        style: AppTextStyles.bodySmall,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '৳${property.price.toInt().toString()}/mo',
                                  style: AppTextStyles.priceSmall.copyWith(color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Advanced Grid - AI Recommended
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'AI Recommended Units',
                  style: AppTextStyles.titleMedium,
                ),
                Text(
                  'See All',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.76,
              ),
              itemCount: verifiedProperties.length,
              itemBuilder: (context, index) {
                final property = verifiedProperties[index];
                return GestureDetector(
                  onTap: () {
                    ref.read(selectedPropertyProvider.notifier).state = property;
                    Navigator.pushNamed(context, AppRoutes.propertyDetails);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.lowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.low),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: AppColors.low,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                const Center(
                                  child: Icon(Icons.apartment_rounded, size: 48, color: AppColors.primary),
                                ),
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: VerifiedBadge(size: 12, showText: true),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.star, color: AppColors.secondary, size: 10),
                                        const SizedBox(width: 2),
                                        Text(
                                          property.rating.toString(),
                                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                property.title,
                                style: AppTextStyles.titleSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                property.area.split(',')[0],
                                style: AppTextStyles.bodySmall,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '৳${property.price.toInt().toString()}/mo',
                                    style: AppTextStyles.priceSmall.copyWith(fontSize: 14),
                                  ),
                                  Text(
                                    '${property.beds} BHK',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // OWNER VIEW
  Widget _buildOwnerDashboard(BuildContext context, List<Property> properties, WidgetRef ref) {
    // Mock owner statistics
    const int totalListings = 2;
    const String rentCollected = '৳1,87,000';
    const int pendingInquiries = 3;
    const int viewsCount = 684;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24, left: 20, right: 20),
      key: const ValueKey('owner'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          // Owner stats grid using bento box layout style
          Row(
            children: [
              Expanded(
                child: _buildBentoStatCard(
                  title: 'Active Listings',
                  value: totalListings.toString(),
                  icon: Icons.home_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildBentoStatCard(
                  title: 'Total Monthly Rent',
                  value: rentCollected,
                  icon: Icons.payments_outlined,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildBentoStatCard(
                  title: 'Pending Offers',
                  value: pendingInquiries.toString(),
                  icon: Icons.notification_important_outlined,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildBentoStatCard(
                  title: 'Monthly Page Views',
                  value: viewsCount.toString(),
                  icon: Icons.trending_up,
                  color: const Color(0xff1877F2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Prominent CTA to list property
          CustomButton(
            text: 'List New Property',
            icon: Icons.add_circle_outline,
            isPrimary: true, // uses primary brand green
            onPressed: () {
              // Note: trigger bottom nav bar index change to 2 (Create Listing tab)
              final parentState = context.findAncestorStateOfType<_DashboardPageState>();
              if (parentState != null) {
                parentState.setState(() {
                  parentState._activeNavIndex = 2;
                });
              }
            },
          ),
          const SizedBox(height: 28),

          // Owner Listings Section Title
          Text(
            'Your Properties',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: 12),

          // Owner listed properties cards
          ...List.generate(2, (index) {
            final property = properties[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.low),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.01),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.low,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.apartment_rounded, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property.title,
                          style: AppTextStyles.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '৳${property.price.toInt().toString()}/month • ${property.beds} BHK',
                          style: AppTextStyles.bodySmall,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Active',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${124 + index * 45} views this week',
                              style: TextStyle(
                                color: AppColors.textLight,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
                    onPressed: () {},
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBentoStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.low),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
