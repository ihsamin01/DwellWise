import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_colors.dart';
import '../../config/app_strings.dart';
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
import '../../widgets/language_toggle.dart';
import '../../widgets/property_card.dart';
import '../../widgets/filter_chip.dart';

/// Price-based filter options for the AI recommended feed.
enum PriceFilter { none, under10k, range10to20k, range20to30k, above30k }

/// Tenant Home Screen containing search bar, horizontal recently viewed, and infinite scrolling AI recommended items.
class TenantHomeScreen extends StatefulWidget {
  final bool showBottomNavigation;

  const TenantHomeScreen({
    super.key,
    this.showBottomNavigation = true,
  });

  @override
  State<TenantHomeScreen> createState() => TenantHomeScreenState();
}

class TenantHomeScreenState extends State<TenantHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  int _displayedCount = 10;
  PriceFilter _priceFilter = PriceFilter.none;
  String? _typeFilter;
  int? _bedsFilter;
  int? _bathsFilter;
  bool _verifiedOnly = false;
  String _sortBy = 'Newest';

  /// Set once the user picks a sort themselves. Until then the feed is
  /// ordered by relevance; after it, the chosen order is left alone.
  bool _userSorted = false;

  /// Bedroom/bathroom quick-pick options.
  static const List<int> kBedsOptions = [1, 2, 3, 4];
  static const List<int> kBathsOptions = [1, 2, 3];

  /// Whether any price/type/beds/baths/verified filter is currently applied.
  bool get hasActiveFilters =>
      _priceFilter != PriceFilter.none ||
      _typeFilter != null ||
      _bedsFilter != null ||
      _bathsFilter != null ||
      _verifiedOnly;

  /// Resets all active filters back to the default, unfiltered feed.
  void clearFilters() {
    if (!hasActiveFilters) return;
    setState(() {
      _priceFilter = PriceFilter.none;
      _typeFilter = null;
      _bedsFilter = null;
      _bathsFilter = null;
      _verifiedOnly = false;
    });
  }

  // AI Recommended (Gemini).
  final GeminiService _gemini = GeminiService();
  List<String>? _aiOrderedIds;
  String? _aiRankedFor;

  /// Kicks off a Gemini ranking for [userAddress] (once per address).
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

  /// Reorders [list] to put Gemini's recommended ids first (in its order),.
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

  /// Sort options shared with the search results screen.
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

  /// Applies the active price/type/beds/baths/verified filters to the recommended list.
  List<PropertyModel> _applyFilters(List<PropertyModel> list) {
    var result = List<PropertyModel>.from(list);

    switch (_priceFilter) {
      case PriceFilter.under10k:
        result = result.where((p) => p.price < 10000).toList();
        break;
      case PriceFilter.range10to20k:
        result = result.where((p) => p.price >= 10000 && p.price < 20000).toList();
        break;
      case PriceFilter.range20to30k:
        result = result.where((p) => p.price >= 20000 && p.price < 30000).toList();
        break;
      case PriceFilter.above30k:
        result = result.where((p) => p.price >= 30000).toList();
        break;
      case PriceFilter.none:
        break;
    }

    if (_typeFilter != null) {
      result = result.where((p) => p.propertyType == _typeFilter).toList();
    }

    if (_bedsFilter != null) {
      final isMax = _bedsFilter == kBedsOptions.last;
      result = isMax
          ? result.where((p) => p.beds >= _bedsFilter!).toList()
          : result.where((p) => p.beds == _bedsFilter).toList();
    }

    if (_bathsFilter != null) {
      final isMax = _bathsFilter == kBathsOptions.last;
      result = isMax
          ? result.where((p) => p.baths >= _bathsFilter!).toList()
          : result.where((p) => p.baths == _bathsFilter).toList();
    }

    if (_verifiedOnly) {
      result = result.where((p) => p.isVerified).toList();
    }

    return result;
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
      context.read<RecentlyViewedProvider>().loadRecentlyViewedIds();
    });
  }

  /// Pull-to-refresh.
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
      // Trigger infinite scroll load more.
      setState(() {
        _displayedCount += 5;
      });
    }
  }

  void _handlePropertyTap(BuildContext context, PropertyModel property) {
    // Add to recently viewed provider dynamically.
    context.read<RecentlyViewedProvider>().addProperty(property.id);
    // Navigate to property details.
    context.push('/property/${property.id}');
  }

  void _handleSaveToggle(BuildContext context,
      SavedPropertiesProvider savedProvider, PropertyModel property) {
    final isSaved = savedProvider.isSaved(property.id);
    savedProvider.toggleSave(property.id, property: property);

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

  /// Sort trigger (Newest / Price) shown at the right of the "AI Recommended".
  Widget _buildSortButton(AppColors colors) {
    return PopupMenuButton<String>(
      tooltip: 'Sort listings',
      offset: const Offset(0, 40),
      color: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) => setState(() {
        _sortBy = value;
        _userSorted = true;
      }),
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
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        decoration: BoxDecoration(
          color: colors.primaryTint,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.swap_vert, size: 14, color: colors.primary),
            const SizedBox(width: 3),
            Text(
              AppStrings.t(context, 'sort'),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Filter trigger shown at the right of the "AI Recommended" heading.
  Widget _buildFilterButton(AppColors colors, List<String> availableTypes) {
    final bool isActive = _priceFilter != PriceFilter.none ||
        _typeFilter != null ||
        _bedsFilter != null ||
        _bathsFilter != null ||
        _verifiedOnly;
    return GestureDetector(
      onTap: () => _openFilterSheet(colors, availableTypes),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? colors.primary : colors.primaryTint,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune,
              size: 14,
              color: isActive ? Colors.white : colors.primary,
            ),
            const SizedBox(width: 3),
            Text(
              AppStrings.t(context, 'filter'),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFilterSheet(AppColors colors, List<String> availableTypes) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        // Local draft state so picks only apply once "Apply Filters" is tapped.
        PriceFilter draftPrice = _priceFilter;
        String? draftType = _typeFilter;
        int? draftBeds = _bedsFilter;
        int? draftBaths = _bathsFilter;
        bool draftVerified = _verifiedOnly;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            Widget sectionTitle(String text) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                );

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Filter Properties',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
                            ),
                          ),
                          TextButton(
                            onPressed: () => setSheetState(() {
                              draftPrice = PriceFilter.none;
                              draftType = null;
                              draftBeds = null;
                              draftBaths = null;
                              draftVerified = false;
                            }),
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      sectionTitle('Price'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: PriceFilter.values.map((filter) {
                          return DwellFilterChip(
                            label: _filterLabel(filter),
                            isSelected: draftPrice == filter,
                            onSelected: (_) =>
                                setSheetState(() => draftPrice = filter),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      sectionTitle('Property Type'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          DwellFilterChip(
                            label: 'All',
                            isSelected: draftType == null,
                            onSelected: (_) =>
                                setSheetState(() => draftType = null),
                          ),
                          ...availableTypes.map((type) => DwellFilterChip(
                                label: type,
                                isSelected: draftType == type,
                                onSelected: (_) =>
                                    setSheetState(() => draftType = type),
                              )),
                        ],
                      ),
                      const SizedBox(height: 20),

                      sectionTitle('Bedrooms'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          DwellFilterChip(
                            label: 'Any',
                            isSelected: draftBeds == null,
                            onSelected: (_) =>
                                setSheetState(() => draftBeds = null),
                          ),
                          ...kBedsOptions.map((n) => DwellFilterChip(
                                label: n == kBedsOptions.last ? '$n+' : '$n',
                                isSelected: draftBeds == n,
                                onSelected: (_) =>
                                    setSheetState(() => draftBeds = n),
                              )),
                        ],
                      ),
                      const SizedBox(height: 20),

                      sectionTitle('Bathrooms'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          DwellFilterChip(
                            label: 'Any',
                            isSelected: draftBaths == null,
                            onSelected: (_) =>
                                setSheetState(() => draftBaths = null),
                          ),
                          ...kBathsOptions.map((n) => DwellFilterChip(
                                label: n == kBathsOptions.last ? '$n+' : '$n',
                                isSelected: draftBaths == n,
                                onSelected: (_) =>
                                    setSheetState(() => draftBaths = n),
                              )),
                        ],
                      ),
                      const SizedBox(height: 20),

                      sectionTitle('Owner Verification'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          DwellFilterChip(
                            label: 'Verified owners only',
                            isSelected: draftVerified,
                            onSelected: (selected) =>
                                setSheetState(() => draftVerified = selected),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _priceFilter = draftPrice;
                              _typeFilter = draftType;
                              _bedsFilter = draftBeds;
                              _bathsFilter = draftBaths;
                              _verifiedOnly = draftVerified;
                            });
                            Navigator.of(sheetContext).pop();
                          },
                          child: const Text(
                            'Apply Filters',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
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
    // The last two parts of the address, e.g.
    final userArea = PropertyProvider.deriveArea(userAddress);

    // Make sure ~12 dummy listings exist around the user's area (regenerates.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      propertyProvider.syncAreaFeed(userAddress);
    });

    final allProperties = propertyProvider.properties;
    final availableTypes = allProperties.map((p) => p.propertyType).toSet().toList()
      ..sort();

    // Offline location ranking from the user's area.
    final sorted = _applySort(_applyFilters(allProperties));
    final locationRanked = recommendByLocation(sorted, userArea);

    // Only ask Gemini once the generated area feed is present.
    final feedReady = propertyProvider.hasAreaFeed;
    if (feedReady && userArea != null && userArea.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _requestAiRanking(userArea, locationRanked);
      });
    }
    // An order the user asked for wins over the recommendation. Ranking by
    // location and then by Gemini on top of 'Newest' meant a listing posted a
    // moment ago could still come out halfway down the list.
    final recommendedList =
        _userSorted ? sorted : _applyAiOrder(locationRanked);

    final recentlyViewedIds = recentlyViewedProvider.recentlyViewedIds;

    // Map viewed IDs to actual properties (home feed + search results),.
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
                // While a filter is narrowing the feed, the back arrow
                // replaces the drawer menu -- one clear way back, no clutter.
                if (hasActiveFilters)
                  GestureDetector(
                    onTap: clearFilters,
                    behavior: HitTestBehavior.opaque,
                    child: Icon(Icons.arrow_back, color: colors.primary, size: 24),
                  )
                else
                  GestureDetector(
                    onTap: () => _scaffoldKey.currentState?.openDrawer(),
                    behavior: HitTestBehavior.opaque,
                    child: Icon(Icons.menu, color: colors.primary, size: 24),
                  ),
                const SizedBox(width: 12),
                // Flexible so the title gives way on narrow screens instead of.
                Flexible(
                  child: Text(
                    'DwellWise',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              const Padding(
                padding: EdgeInsets.only(right: 12.0),
                child: LanguageToggle(),
              ),
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
                  // HEADER SECTION.
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.t(context, 'home_hero_title'),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppStrings.t(context, 'home_hero_subtitle'),
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // RECENTLY VIEWED SECTION (Horizontal scroll.
                  if (recentlyViewedList.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings.t(context, 'home_recently_viewed'),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.push('/recently-viewed'),
                            child: Text(
                              AppStrings.t(context, 'home_view_all'),
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

                  // AI RECOMMENDED SECTION -- the heading only makes sense
                  // for the AI's own ranking, so it's dropped entirely while
                  // a filter is active and just the matched posts are shown.
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (!hasActiveFilters)
                          Expanded(
                            child: Text(
                              '🚀 ${AppStrings.t(context, 'home_ai_recommended')}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: colors.textPrimary,
                              ),
                            ),
                          )
                        else
                          const Spacer(),
                        _buildSortButton(colors),
                        const SizedBox(width: 6),
                        _buildFilterButton(colors, availableTypes),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Property card list with infinite scroll (loads more as
                  // the user nears the bottom, capped at the real result
                  // count so it never repeats a property to pad the list).
                  if (recommendedList.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      itemCount: _displayedCount < recommendedList.length
                          ? _displayedCount
                          : recommendedList.length,
                      itemBuilder: (context, index) {
                        final property = recommendedList[index];
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
