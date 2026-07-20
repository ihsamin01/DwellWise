import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/property_provider.dart';
import '../../providers/saved_properties_provider.dart';
import '../../providers/recently_viewed_provider.dart';
import '../../models/property_model.dart';
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
  final ScrollController _scrollController = ScrollController();
  int _displayedCount = 10;
  PriceFilter _priceFilter = PriceFilter.none;

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

  /// Filter/sort trigger shown at the right of the "AI Recommended" heading.
  Widget _buildFilterButton() {
    final bool isActive = _priceFilter != PriceFilter.none;
    return PopupMenuButton<PriceFilter>(
      tooltip: 'Filter by price',
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) => setState(() => _priceFilter = value),
      itemBuilder: (context) => PriceFilter.values.map((filter) {
        final selected = _priceFilter == filter;
        return PopupMenuItem<PriceFilter>(
          value: filter,
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 18,
                color: selected
                    ? const Color(0xff1E40AF)
                    : const Color(0xff9CA3AF),
              ),
              const SizedBox(width: 10),
              Text(
                _filterLabel(filter),
                style: TextStyle(
                  fontSize: 13,
                  color: const Color(0xff1F2937),
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
          color: isActive ? const Color(0xff1E40AF) : const Color(0xffEFF6FF),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune,
              size: 16,
              color: isActive ? Colors.white : const Color(0xff1E40AF),
            ),
            const SizedBox(width: 4),
            Text(
              'Filter',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : const Color(0xff1E40AF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final propertyProvider = context.watch<PropertyProvider>();
    final savedProvider = context.watch<SavedPropertiesProvider>();
    final recentlyViewedProvider = context.watch<RecentlyViewedProvider>();

    final allProperties = propertyProvider.properties;
    final recommendedList = _applyPriceFilter(allProperties);
    final recentlyViewedIds = recentlyViewedProvider.recentlyViewedIds;

    // Map viewed IDs to actual properties (home feed + search results),
    // skipping any id that can no longer be resolved.
    final recentlyViewedList = recentlyViewedIds
        .map(propertyProvider.findById)
        .whereType<PropertyModel>()
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xffF3F4F6),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xffD1D5DB), width: 1.0),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            titleSpacing: 16,
            title: Row(
              children: const [
                Icon(Icons.menu, color: Color(0xff1E40AF), size: 24),
                SizedBox(width: 12),
                Text(
                  'DwellWise',
                  style: TextStyle(
                    color: Color(0xff1E40AF),
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
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Notifications panel coming soon.')),
                    );
                  },
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.notifications_none,
                          color: Color(0xff1E40AF),
                          size: 24,
                        ),
                      ),
                      // Notification badge "94"
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
                          child: const Text(
                            '94',
                            style: TextStyle(
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
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xff1E40AF)),
              ),
            )
          : SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // HEADER SECTION
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Find Your Perfect Home',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff1F2937),
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Explore amazing properties in your city',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xff6B7280),
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
                          const Text(
                            'Recently Viewed',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff1F2937),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.push('/recently-viewed'),
                            child: const Text(
                              'View All',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xff1E40AF),
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
                        const Expanded(
                          child: Text(
                            '🚀 AI Recommended for You',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff1F2937),
                            ),
                          ),
                        ),
                        _buildFilterButton(),
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
                          isSaved: isSaved,
                          onTap: () => _handlePropertyTap(context, property),
                          onSaveTap: () => _handleSaveToggle(
                              context, savedProvider, property),
                        );
                      },
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 40.0),
                      child: Center(
                        child: Text(
                          'No properties match this filter.',
                          style:
                              TextStyle(fontSize: 14, color: Color(0xff6B7280)),
                        ),
                      ),
                    ),

                  const SizedBox(
                      height: 120), // Bottom padding to avoid nav overlap
                ],
              ),
            ),
      bottomNavigationBar: widget.showBottomNavigation
          ? const BottomNavigation(currentIndex: 0)
          : null,
    );
  }
}
