import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_colors.dart';
import '../../providers/property_provider.dart';
import '../../providers/saved_properties_provider.dart';
import '../../providers/recently_viewed_provider.dart';
import '../../providers/search_filters_provider.dart';
import '../../models/property_model.dart';
import '../../services/mock_search_service.dart';
import '../../widgets/bottom_navigation.dart';
import '../../widgets/property_card.dart';

/// Tenant Search Screen: hierarchical Division > District > Thana > Area
/// selection (full Bangladesh dataset), selections shown inside the search
/// box, and location-based results revealed only after pressing Search.
class TenantSearchScreen extends StatefulWidget {
  final bool showBottomNavigation;

  const TenantSearchScreen({
    super.key,
    this.showBottomNavigation = true,
  });

  @override
  State<TenantSearchScreen> createState() => _TenantSearchScreenState();
}

class _TenantSearchScreenState extends State<TenantSearchScreen> {
  bool _hasSearched = false;
  List<PropertyModel> _results = [];

  void _handlePropertyTap(BuildContext context, PropertyModel property) {
    context.read<RecentlyViewedProvider>().addProperty(property.id);
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
        backgroundColor:
            isSaved ? const Color(0xff6B7280) : const Color(0xff10B981),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Any filter change invalidates previous results until Search is pressed.
  void _invalidateResults() {
    setState(() {
      _hasSearched = false;
      _results = [];
    });
  }

  void _runSearch(BuildContext context, SearchFiltersProvider filterProvider) {
    if (!filterProvider.hasSelection) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select at least a Division first')),
      );
      return;
    }

    final propertyProvider = context.read<PropertyProvider>();

    // 1. Location-generated realistic listings.
    final generated = MockSearchService.generate(
      division: filterProvider.division,
      district: filterProvider.district,
      thana: filterProvider.thana,
      area: filterProvider.area,
    );

    // 2. Any home-feed posts that genuinely match the most specific locality.
    final locality = (filterProvider.area.isNotEmpty
            ? filterProvider.area
            : filterProvider.thana.isNotEmpty
                ? filterProvider.thana
                : filterProvider.district)
        .toLowerCase();
    final homeMatches = locality.isEmpty
        ? <PropertyModel>[]
        : propertyProvider.properties
            .where((p) =>
                p.area.toLowerCase().contains(locality) ||
                p.address.toLowerCase().contains(locality))
            .toList();

    // Register generated posts so details/saved/recently screens resolve them.
    propertyProvider.registerSearchResults(generated);

    setState(() {
      _results = [...homeMatches, ...generated];
      _hasSearched = true;
    });
  }

  void _showFilterModal(
      BuildContext context, SearchFiltersProvider filterProvider, String type) {
    final colors = AppColors.of(context);
    List<String> options = [];
    String currentVal = '';
    Function(String) onSelect;

    switch (type) {
      case 'Division':
        options = filterProvider.divisionsList;
        currentVal = filterProvider.division;
        onSelect = (val) => filterProvider.setDivision(val);
        break;
      case 'District':
        if (filterProvider.division.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a Division first')),
          );
          return;
        }
        options =
            filterProvider.getDistrictsForDivision(filterProvider.division);
        currentVal = filterProvider.district;
        onSelect = (val) => filterProvider.setDistrict(val);
        break;
      case 'Thana':
        if (filterProvider.district.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a District first')),
          );
          return;
        }
        options = filterProvider.getThanasForDistrict(filterProvider.district);
        currentVal = filterProvider.thana;
        onSelect = (val) => filterProvider.setThana(val);
        break;
      case 'Area':
        if (filterProvider.thana.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a Thana first')),
          );
          return;
        }
        options = filterProvider.getAreasForThana(filterProvider.thana);
        currentVal = filterProvider.area;
        onSelect = (val) => filterProvider.setArea(val);
        break;
      default:
        return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      ),
      builder: (context) {
        String localSelected = currentVal;
        String query = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final visible = query.isEmpty
                ? options
                : options
                    .where((o) => o.toLowerCase().contains(query.toLowerCase()))
                    .toList();
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Select $type',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary),
                    ),
                    const SizedBox(height: 10),
                    // Quick search within long option lists (e.g. 64 districts)
                    if (options.length > 8)
                      Container(
                        height: 40,
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: colors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search,
                                size: 18, color: colors.textSecondary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                style: TextStyle(
                                    fontSize: 14, color: colors.textPrimary),
                                decoration: InputDecoration(
                                  hintText: 'Type to filter $type list...',
                                  hintStyle: TextStyle(
                                      fontSize: 13, color: colors.textSecondary),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                onChanged: (val) =>
                                    setModalState(() => query = val),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Flexible(
                      child: visible.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20.0),
                              child: Text('No options available.',
                                  style: TextStyle(color: colors.textSecondary)),
                            )
                          : ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.5,
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: visible.length,
                                itemBuilder: (context, index) {
                                  final opt = visible[index];
                                  return RadioListTile<String>(
                                    title: Text(opt,
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: colors.textPrimary)),
                                    value: opt,
                                    groupValue: localSelected,
                                    activeColor: colors.primary,
                                    dense: true,
                                    onChanged: (val) {
                                      setModalState(() {
                                        localSelected = val ?? '';
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffF59E0B), // CTA Orange
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        if (localSelected.isNotEmpty) {
                          onSelect(localSelected);
                          _invalidateResults();
                        }
                        Navigator.pop(context);
                      },
                      child: const Text('Apply Filter',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
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
    final savedProvider = context.watch<SavedPropertiesProvider>();
    final filterProvider = context.watch<SearchFiltersProvider>();

    // Apply sorting to the searched results.
    final sortedResults = List<PropertyModel>.from(_results);
    if (filterProvider.sortBy == 'Price Low-High') {
      sortedResults.sort((a, b) => a.price.compareTo(b.price));
    } else if (filterProvider.sortBy == 'Price High-Low') {
      sortedResults.sort((a, b) => b.price.compareTo(a.price));
    }

    final selectionPath = filterProvider.selectionPath;
    final mostSpecific = filterProvider.area.isNotEmpty
        ? filterProvider.area
        : filterProvider.thana.isNotEmpty
            ? filterProvider.thana
            : filterProvider.district.isNotEmpty
                ? filterProvider.district
                : filterProvider.division;

    return Scaffold(
      backgroundColor: colors.background,
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
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: colors.primary, size: 24),
              onPressed: () => context.go('/home'),
            ),
            title: Text(
              'DwellWise',
              style: TextStyle(
                color: colors.primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(Icons.share_outlined, color: colors.primary, size: 24),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share copy triggered.')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. SEARCH BOX — displays the selected location path
          Container(
            color: colors.surface,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selectionPath.isEmpty ? colors.border : colors.primary,
                  width: selectionPath.isEmpty ? 1.0 : 1.5,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.search, color: colors.textSecondary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: selectionPath.isEmpty
                        ? Text(
                            'Select your location below...',
                            style: TextStyle(
                                color: colors.textSecondary, fontSize: 15),
                            overflow: TextOverflow.ellipsis,
                          )
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              selectionPath,
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.location_on, color: colors.textSecondary),
                ],
              ),
            ),
          ),

          // 2. FILTER BUTTONS SECTION (Division, District, Thana, Area)
          Container(
            color: colors.surface,
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'FILTERS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        filterProvider.clearAll();
                        _invalidateResults();
                      },
                      child: Text(
                        'Clear All',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Horizontal scrollable buttons
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildFilterButton(
                        colors: colors,
                        label: filterProvider.division.isEmpty
                            ? 'Division ▼'
                            : '${filterProvider.division} ▼',
                        isActive: filterProvider.division.isNotEmpty,
                        onTap: () => _showFilterModal(
                            context, filterProvider, 'Division'),
                      ),
                      _buildFilterButton(
                        colors: colors,
                        label: filterProvider.district.isEmpty
                            ? 'District ▼'
                            : '${filterProvider.district} ▼',
                        isActive: filterProvider.district.isNotEmpty,
                        onTap: () => _showFilterModal(
                            context, filterProvider, 'District'),
                      ),
                      _buildFilterButton(
                        colors: colors,
                        label: filterProvider.thana.isEmpty
                            ? 'Thana ▼'
                            : '${filterProvider.thana} ▼',
                        isActive: filterProvider.thana.isNotEmpty,
                        onTap: () =>
                            _showFilterModal(context, filterProvider, 'Thana'),
                      ),
                      _buildFilterButton(
                        colors: colors,
                        label: filterProvider.area.isEmpty
                            ? 'Area ▼'
                            : '${filterProvider.area} ▼',
                        isActive: filterProvider.area.isNotEmpty,
                        onTap: () =>
                            _showFilterModal(context, filterProvider, 'Area'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 3. SEARCH BUTTON
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffF59E0B), // CTA Orange
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    elevation: 0,
                  ),
                  onPressed: () => _runSearch(context, filterProvider),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.search, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Search',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // Divider line
          Container(height: 1, color: colors.border),

          // 4. RESULTS — only after pressing Search
          if (_hasSearched) ...[
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Showing ${sortedResults.length} results in $mostSpecific',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                  DropdownButton<String>(
                    value: filterProvider.sortBy,
                    underline: const SizedBox.shrink(),
                    icon: Icon(Icons.keyboard_arrow_down,
                        size: 16, color: colors.primary),
                    dropdownColor: colors.surface,
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    onChanged: (val) {
                      if (val != null) filterProvider.setSortBy(val);
                    },
                    items: const [
                      DropdownMenuItem(
                          value: 'Newest', child: Text('Sort: Newest')),
                      DropdownMenuItem(
                          value: 'Price Low-High',
                          child: Text('Price: Low-High')),
                      DropdownMenuItem(
                          value: 'Price High-Low',
                          child: Text('Price: High-Low')),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: sortedResults.isEmpty
                  ? Center(
                      child: Text(
                        'No properties found for this location.',
                        style: TextStyle(color: colors.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 120.0),
                      itemCount: sortedResults.length,
                      itemBuilder: (context, index) {
                        final property = sortedResults[index];
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
                    ),
            ),
          ] else
            // Pre-search empty state: clean, no images
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.travel_explore, size: 56, color: colors.border),
                    const SizedBox(height: 14),
                    Text(
                      'Select your location and press Search',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Division > District > Thana > Area',
                      style: TextStyle(fontSize: 12, color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: widget.showBottomNavigation
          ? const BottomNavigation(currentIndex: 1)
          : null,
    );
  }

  Widget _buildFilterButton({
    required AppColors colors,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? colors.primaryTint : colors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? colors.primary : colors.border,
              width: isActive ? 1.5 : 1.0,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? colors.primary : colors.textPrimary,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
