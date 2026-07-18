import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/property_provider.dart';
import '../../providers/search_provider.dart';
import '../../models/property_model.dart';
import '../../widgets/bottom_navigation.dart';
import '../../widgets/global_app_bar.dart';

/// Screen representing tenant search query results and filters.
class TenantSearchScreen extends StatefulWidget {
  const TenantSearchScreen({Key? key}) : super(key: key);

  @override
  State<TenantSearchScreen> createState() => _TenantSearchScreenState();
}

class _TenantSearchScreenState extends State<TenantSearchScreen> {
  final _searchController = TextEditingController();
  bool _showPriceSlider = false;
  bool _hasRoomsFilter = true;
  String _selectedSort = 'Newest';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<SearchProvider>().updateSearchQuery(_searchController.text);
  }

  void _toggleFavorite(BuildContext context, PropertyProvider provider, PropertyModel property) {
    final isSaved = provider.isSaved(property.id);
    provider.toggleFavorite(property.id);
    
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isSaved ? 'Removed from favorites' : 'Added to favorites'),
        backgroundColor: isSaved ? const Color(0xff6B7280) : const Color(0xff10B981),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = context.watch<SearchProvider>();
    final propertyProvider = context.watch<PropertyProvider>();

    // Apply custom slider limits from specs: Min 25,000, Max 50,000 if not adjusted
    // Let's filter based on search query, category, price range, and bedrooms
    final sourceList = propertyProvider.properties;
    
    // Apply filters from provider state
    var filteredListings = searchProvider.filterListings(sourceList);

    // Apply mock rooms filter condition if rooms chip is active (e.g. 3+ rooms)
    if (_hasRoomsFilter) {
      filteredListings = filteredListings.where((p) => p.beds >= 3).toList();
    }

    // Apply mock price range slide from specs (25k - 50k range slider)
    filteredListings = filteredListings.where((p) {
      return p.price >= searchProvider.priceRange.start && p.price <= searchProvider.priceRange.end;
    }).toList();

    // Sort listings mock representation
    if (_selectedSort == 'Price') {
      filteredListings.sort((a, b) => a.price.compareTo(b.price));
    } else if (_selectedSort == 'Rating') {
      filteredListings.sort((a, b) => b.id.compareTo(a.id)); // mock sort
    }

    return Scaffold(
      backgroundColor: const Color(0xffF3F4F6),
      appBar: const GlobalAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. SEARCH HEADER SECTION (Sticky at top)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xffD1D5DB)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Color(0xff6B7280)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Color(0xff1F2937)),
                      decoration: const InputDecoration(
                        hintText: 'Search neighborhood or city...',
                        hintStyle: TextStyle(color: Color(0xff9CA3AF)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const Icon(Icons.location_on_outlined, color: Color(0xff6B7280)),
                ],
              ),
            ),
          ),

          // 2. FILTERS SECTION (Sticky below search)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff1F2937),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        searchProvider.resetFilters();
                        _searchController.clear();
                        setState(() {
                          _hasRoomsFilter = false;
                          _showPriceSlider = false;
                        });
                      },
                      child: const Text(
                        'Clear all',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xff1E40AF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // Budget chip (toggles collapsible slider)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showPriceSlider = !_showPriceSlider;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xff1E40AF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: const [
                              Text(
                                'Budget ▼',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Rooms chip (with removal)
                      if (_hasRoomsFilter) ...[
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _hasRoomsFilter = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xff1E40AF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: const [
                                Text(
                                  '3+ Rooms ✕',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],

                      // Property type chip (static UI)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xffF3F4F6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xffD1D5DB)),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Apartment',
                          style: TextStyle(
                            color: Color(0xff1F2937),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. COLLAPSIBLE PRICE RANGE SLIDER
          AnimatedCrossFade(
            firstChild: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  const Text(
                    'PRICE RANGE (MONTHLY)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff6B7280),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '৳${(searchProvider.priceRange.start / 1000).toStringAsFixed(0)}k - ৳${(searchProvider.priceRange.end / 1000).toStringAsFixed(0)}k',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff1F2937),
                    ),
                  ),
                  RangeSlider(
                    values: searchProvider.priceRange,
                    min: 25000,
                    max: 150000,
                    divisions: 25,
                    activeColor: const Color(0xff1E40AF),
                    inactiveColor: const Color(0xffD1D5DB),
                    onChanged: (val) {
                      searchProvider.updatePriceRange(val);
                    },
                  ),
                ],
              ),
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState: _showPriceSlider ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 200),
          ),

          // 4. RESULTS COUNT HEADER SECTION
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing ${filteredListings.length} results in Dhaka',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xff6B7280),
                  ),
                ),
                // Sort Dropdown
                DropdownButton<String>(
                  value: _selectedSort,
                  underline: const SizedBox.shrink(),
                  icon: const Icon(Icons.arrow_drop_down, color: Color(0xff1E40AF)),
                  style: const TextStyle(
                    color: Color(0xff1E40AF),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedSort = val;
                      });
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: 'Newest', child: Text('Sort: Newest')),
                    DropdownMenuItem(value: 'Price', child: Text('Sort: Price')),
                    DropdownMenuItem(value: 'Rating', child: Text('Sort: Rating')),
                  ],
                ),
              ],
            ),
          ),

          // 5. RESULTS LIST (Scrolls below filters)
          Expanded(
            child: filteredListings.isEmpty
                ? const Center(
                    child: Text(
                      'No matches found for your filter criteria.',
                      style: TextStyle(color: Color(0xff6B7280)),
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: filteredListings.length,
                    itemBuilder: (context, index) {
                      final property = filteredListings[index];
                      final isSaved = propertyProvider.isSaved(property.id);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 20.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xffD1D5DB)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: property.imageUrls.isNotEmpty
                                        ? property.imageUrls[0]
                                        : 'https://placeholder.com/600',
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey.shade200,
                                      height: 200,
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => const Icon(Icons.error),
                                  ),
                                ),
                                // Verified Badge
                                if (property.isVerified)
                                  Positioned(
                                    top: 12,
                                    left: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        children: const [
                                          Icon(Icons.verified, color: Color(0xff10B981), size: 14),
                                          SizedBox(width: 4),
                                          Text(
                                            'Verified',
                                            style: TextStyle(
                                              color: Color(0xff10B981),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                // Heart button
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: GestureDetector(
                                    onTap: () => _toggleFavorite(context, propertyProvider, property),
                                    child: CircleAvatar(
                                      backgroundColor: Colors.white.withOpacity(0.9),
                                      child: Icon(
                                        isSaved ? Icons.favorite : Icons.favorite_border,
                                        color: isSaved ? const Color(0xffDC2626) : const Color(0xffD1D5DB),
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            // Property details
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    property.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff1F2937),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        '৳${property.price.toInt()}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xff1E40AF),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'per month',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xff6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${property.beds} Bed  ${property.baths} Bath  ${property.sizeSqFt.toInt()} sqft',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xff6B7280),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined, size: 14, color: Color(0xff6B7280)),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          property.address,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xff6B7280),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    property.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xff6B7280),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // View on Map Button
                                  GestureDetector(
                                    onTap: () => context.go('/map-view'),
                                    child: Container(
                                      height: 36,
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xff1E40AF),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Center(
                                        widthFactor: 1,
                                        child: Text(
                                          'View on Map',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 56), // bottom clearance for bottom nav
        ],
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 1),
    );
  }
}
