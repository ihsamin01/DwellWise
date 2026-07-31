import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_colors.dart';
import '../../providers/notification_provider.dart';
import '../../providers/property_provider.dart';
import '../../providers/saved_properties_provider.dart';
import '../../providers/recently_viewed_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/property_model.dart';
import '../../services/gemini_service.dart';
import '../../utils/location_recommender.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/bottom_navigation.dart';
import '../../widgets/property_card.dart';

/// Price-based filter options for the AI recommended feed.
/// [none] is the initial "no filter applied" state and is not shown as a
/// selectable menu item — only the four price buckets are listed.
enum PriceFilter { none, under10k, range10to20k, range20to30k, above30k }

/// Tenant Home Screen containing search bar, horizontal recently viewed, and infinite scrolling AI recommended items.
class TenantHomeScreen extends StatefulWidget {
  final bool showBottomNavigation;

  const TenantHomeScreen({
    super.key,
    this.showBottomNavigation = true,
  });

  @override
  State<TenantHomeScreen> createState() => _TenantHomeScreenState();
}

class _TenantHomeScreenState extends State<TenantHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  int _displayedCount = 10;
  PriceFilter _priceFilter = PriceFilter.none;

  /// Menu value for the "Verified only" toggle (it sits alongside the price
  /// options but behaves as an independent checkbox).
  static const String _kVerifiedFilter = 'verified-only';
  bool _verifiedOnly = false;

  String _sortBy = 'Newest';

  // AI Recommended (Gemini) — refines the local location ranking in the
  // background; falls back to the local ranking on any error.
  final GeminiService _gemini = GeminiService();
  List<String>? _aiOrderedIds;
  String? _aiRankedFor;

  /// Kicks off a Gemini ranking for [userAddress] (once per address). Resets the
  /// previous order when the address changes.
  Future<void> _requestAiRanking(
      String userAddress, List<PropertyModel> candidates) async {
    if (_aiRankedFor == userAddress) return;
    _aiRankedFor = userAddress;
    _aiOrderedIds = null; // drop stale order for the new location
    final ids = await _gemini.recommendPropertyIds(
      userLocation: userAddress,
      candidates: candidates,
    );
    if (mounted && _aiRankedFor == userAddress) {
      setState(() => _aiOrderedIds = ids.isNotEmpty ? ids : null);
    }
  }

  /// Reorders [list] to put Gemini's recommended ids first (in its order),
  /// keeping the rest in their existing order.
  List<PropertyModel> _applyAiOrder(List<PropertyModel> list) {
    final ids = _aiOrderedIds;
    if (ids == null || ids.isEmpty) return list;
    final byId = {for (final p in list) p.id: p};
    final ordered = <PropertyModel>[];
    for (final id in ids) {
      final p = byId.remove(id);
      if (p != null) ordered.add(p);
    }
    ordered.addAll(list.where((p) => byId.containsKey(p.id)));
    return ordered;
  }

  /// Sort options shared with the search results screen. Value → label.
  static const Map<String, String> kSortOptions = {
    'Newest': 'Newest',
    'Price Low-High': 'Price: Low to High',
    'Price High-Low': 'Price: High to Low',
  };

  /// Orders the list by the active sort (newest post first by default).
  List<PropertyModel> _applySort(List<PropertyModel> list) {
    final result = List<PropertyModel>.from(list);
    switch (_sortBy) {
      case 'Price Low-High':
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price High-Low':
        result.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Newest':
      default:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return result;
  }

  /// Applies the active price filter/sort to the recommended list.
  List<PropertyModel> _applyPriceFilter(List<PropertyModel> list) {
    final result = List<PropertyModel>.from(list);
    switch (_priceFilter) {
      case PriceFilter.under10k:
        return result.where((p) => p.price < 10000).toList();
      case PriceFilter.range10to20k:
        return result.where((p) => p.price >= 10000 && p.price < 20000).toList();
      case PriceFilter.range20to30k:
        return result.where((p) => p.price >= 20000 && p.price < 30000).toList();
      case PriceFilter.above30k:
        return result.where((p) => p.price >= 30000).toList();
      case PriceFilter.none:
        return result;
    }
  }

  /// Keeps only listings posted by verified owners when the toggle is on.
  List<PropertyModel> _applyVerifiedFilter(List<PropertyModel> list) {
    if (!_verifiedOnly) return list;
    return list.where((p) => p.isVerified).toList();
  }

  String _filterLabel(PriceFilter filter) {
    switch (filter) {
      case PriceFilter.none:
        return 'All properties';
      case PriceFilter.under10k:
        return 'Under ৳10,000';
      case PriceFilter.range10to20k:
        return '৳10,000 – ৳20,000';
      case PriceFilter.range20to30k:
        return '৳20,000 – ৳30,000';
      case PriceFilter.above30k:
        return 'Above ৳30,000';
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropertyProvider>().fetchProperties();
    });
  }

  /// Pull-to-refresh: re-reads the listings (so newly posted rentals from other
  /// devices show up) and rebuilds the area feed for [userAddress].
  Future<void> _refreshFeed(String? userAddress) async {
    final provider = context.read<PropertyProvider>();
    await provider.fetchProperties();
    await provider.syncAreaFeed(userAddress, force: true);
    _aiRankedFor = null; // let Gemini re-rank the refreshed list
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Trigger infinite scroll load more
      setState(() {
        _displayedCount += 5;
      });
    }
  }

  void _handlePropertyTap(BuildContext context, PropertyModel property) {
    // Add to recently viewed provider dynamically
    context.read<RecentlyViewedProvider>().addProperty(property.id);
    // Navigate to property details
    context.push('/property/${property.id}');
  }

  void _handleSaveToggle(BuildContext context,
      SavedPropertiesProvider savedProvider, PropertyModel property) {
    final isSaved = savedProvider.isSaved(property.id);
    savedProvider.toggleSave(property.id);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(isSaved ? 'Removed from favorites' : 'Added to favorites'),
        backgroundColor: isSaved
            ? const Color(0xff6B7280)
            : const Color(0xff10B981), // Emerald Green on save
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Sort trigger (Newest / Price) shown at the right of the "AI Recommended"
  /// heading, next to the price Filter button.
  Widget _buildSortButton(AppColors colors) {
    return PopupMenuButton<String>(
      tooltip: 'Sort listings',
      offset: const Offset(0, 40),
      color: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) => setState(() => _sortBy = value),
      itemBuilder: (context) => kSortOptions.entries.map((e) {
        final selected = _sortBy == e.key;
        return PopupMenuItem<String>(
          value: e.key,
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                size: 18,
                color: selected ? colors.primary : colors.textSecondary,
              ),
              const SizedBox(width: 10),
              Text(
                e.value,
                style: TextStyle(
                  fontSize: 13,
                  color: colors.textPrimary,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: colors.primaryTint,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.swap_vert, size: 16, color: colors.primary),
            const SizedBox(width: 4),
            Text(
              'Sort',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Filter/sort trigger shown at the right of the "AI Recommended" heading.
  Widget _buildFilterButton(AppColors colors) {
    final bool isActive = _priceFilter != PriceFilter.none || _verifiedOnly;
    return PopupMenuButton<Object>(
      tooltip: 'Filter listings',
      offset: const Offset(0, 40),
      color: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) => setState(() {
        if (value is PriceFilter) {
          _priceFilter = value;
        } else if (value == _kVerifiedFilter) {
          _verifiedOnly = !_verifiedOnly;
        }
      }),
      itemBuilder: (context) => [
        ...PriceFilter.values.map((filter) {
          final selected = _priceFilter == filter;
          return PopupMenuItem<Object>(
            value: filter,
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 18,
                  color: selected ? colors.primary : colors.textSecondary,
                ),
                const SizedBox(width: 10),
                Text(
                  _filterLabel(filter),
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.textPrimary,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }),
        const PopupMenuDivider(),
        // Independent toggle: show only listings posted by verified owners.
        PopupMenuItem<Object>(
          value: _kVerifiedFilter,
          child: Row(
            children: [
              Icon(
                _verifiedOnly ? Icons.check_box : Icons.check_box_outline_blank,
                size: 18,
                color: _verifiedOnly ? colors.primary : colors.textSecondary,
              ),
              const SizedBox(width: 10),
              const Icon(Icons.verified, size: 16, color: Color(0xff10B981)),
              const SizedBox(width: 6),
              Text(
                'Verified only',
                style: TextStyle(
                  fontSize: 13,
                  color: colors.textPrimary,
                  fontWeight:
                      _verifiedOnly ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? colors.primary : colors.primaryTint,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune,
              size: 16,
              color: isActive ? Colors.white : colors.primary,
            ),
            const SizedBox(width: 4),
            Text(
              'Filter',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final unreadNotifications = context.watch<NotificationProvider>().unreadCount;
    final propertyProvider = context.watch<PropertyProvider>();
    final savedProvider = context.watch<SavedPropertiesProvider>();
    final recentlyViewedProvider = context.watch<RecentlyViewedProvider>();

    final userAddress = context.watch<UserProvider>().userModel?.address;
    // The last two parts of the address, e.g. "Banani, Dhaka" — everything
    // (feed generation, ranking, Gemini) keys off this.
    final userArea = PropertyProvider.deriveArea(userAddress);

    // Make sure ~12 dummy listings exist around the user's area (regenerates
    // only when the area changes). Runs post-frame since it notifies listeners.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      propertyProvider.syncAreaFeed(userAddress);
    });

    final allProperties = propertyProvider.properties;

    // Offline location ranking from the user's area, then let Gemini refine the
    // order in the background (falls back to the local ranking).
    final sorted =
        _applySort(_applyVerifiedFilter(_applyPriceFilter(allProperties)));
    final locationRanked = recommendByLocation(sorted, userArea);

    // Only ask Gemini once the generated area feed is present, so it ranks the
    // nearby posts too (keeps them on top).
    final feedReady = propertyProvider.hasAreaFeed;
    if (feedReady && userArea != null && userArea.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _requestAiRanking(userArea, locationRanked);
      });
    }
    final recommendedList = _applyAiOrder(locationRanked);

    final recentlyViewedIds = recentlyViewedProvider.recentlyViewedIds;

    // Map viewed IDs to actual properties (home feed + search results),
    // skipping any id that can no longer be resolved.
    final recentlyViewedList = recentlyViewedIds
        .map(propertyProvider.findById)
        .whereType<PropertyModel>()
        .toList();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colors.background,
      drawer: const AppDrawer(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(
              bottom: BorderSide(color: colors.border, width: 1.0),
            ),
          ),
          child: AppBar(
            backgroundColor: colors.surface,
            elevation: 0,
            automaticallyImplyLeading: false,
            titleSpacing: 16,
            title: Row(
              children: [
                GestureDetector(
                  onTap: () => _scaffoldKey.currentState?.openDrawer(),
                  behavior: HitTestBehavior.opaque,
                  child: Icon(Icons.menu, color: colors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  'DwellWise',
                  style: TextStyle(
                    color: colors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GestureDetector(
                  onTap: () => context.push('/notifications'),
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.notifications_none,
                          color: colors.primary,
                          size: 24,
                        ),
                      ),
                      // Unread notification badge — hidden at zero.
                      if (unreadNotifications > 0)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Color(0xffDC2626),
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 14,
                              minHeight: 14,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$unreadNotifications',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 7,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: propertyProvider.isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
              ),
            )
          : RefreshIndicator(
              color: colors.primary,
              onRefresh: () => _refreshFeed(userAddress),
              child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // HEADER SECTION
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Find Your Perfect Home',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Explore amazing properties in your city',
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // RECENTLY VIEWED SECTION (Horizontal scroll, hidden if empty)
                  if (recentlyViewedList.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recently Viewed',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.push('/recently-viewed'),
                            child: Text(
                              'View All',
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 156,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        itemCount: recentlyViewedList.length,
                        itemBuilder: (context, index) {
                          final property = recentlyViewedList[index];
                          final isSaved = savedProvider.isSaved(property.id);

                          return PropertyCard(
                            property: property,
                            showDetails: false,
                            isSaved: isSaved,
                            onTap: () => _handlePropertyTap(context, property),
                            onSaveTap: () => _handleSaveToggle(
                                context, savedProvider, property),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // AI RECOMMENDED SECTION
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '🚀 AI Recommended',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                        _buildSortButton(colors),
                        const SizedBox(width: 8),
                        _buildFilterButton(colors),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Property card list with infinite scroll builder loop
                  if (recommendedList.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      itemCount: _displayedCount,
                      itemBuilder: (context, index) {
                        // Loop indices to support infinite list scrolling simulation
                        final property =
                            recommendedList[index % recommendedList.length];
                        final isSaved = savedProvider.isSaved(property.id);

                        return PropertyCard(
                          property: property,
                          showDetails: true,
                          showDate: _sortBy == 'Newest',
                          isSaved: isSaved,
                          onTap: () => _handlePropertyTap(context, property),
                          onSaveTap: () => _handleSaveToggle(
                              context, savedProvider, property),
                        );
                      },
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 40.0),
                      child: Center(
                        child: Text(
                          'No properties match this filter.',
                          style: TextStyle(fontSize: 14, color: colors.textSecondary),
                        ),
                      ),
                    ),

                  const SizedBox(
                      height: 120), // Bottom padding to avoid nav overlap
                ],
              ),
            ),
            ),
      bottomNavigationBar: widget.showBottomNavigation
          ? const BottomNavigation(currentIndex: 0)
          : null,
    );
  }
}
