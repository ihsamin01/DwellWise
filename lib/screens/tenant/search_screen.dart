import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/property_provider.dart';
import '../../providers/saved_properties_provider.dart';
import '../../providers/recently_viewed_provider.dart';
import '../../providers/search_filters_provider.dart';
import '../../models/property_model.dart';
import '../../widgets/bottom_navigation.dart';
import '../../widgets/property_card.dart';

/// Tenant Search Screen with autocomplete suggestions, hierarchical bottom sheet modals and dynamic sort selectors.
class TenantSearchScreen extends StatefulWidget {
  const TenantSearchScreen({Key? key}) : super(key: key);

  @override
  State<TenantSearchScreen> createState() => _TenantSearchScreenState();
}

class _TenantSearchScreenState extends State<TenantSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  String _searchQuery = '';
  bool _showSuggestions = false;
  final List<String> _autocompletePool = ['Dhaka', 'Gulshan', 'Banani', 'Dhanmondi', 'Uttara', 'Mirpur', 'Gazipur'];
  List<String> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchQueryChanged);
    _searchFocusNode.addListener(_onSearchFocusChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchQueryChanged);
    _searchFocusNode.removeListener(_onSearchFocusChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchQueryChanged() {
    final text = _searchController.text.trim();
    setState(() {
      _searchQuery = text;
      if (text.isNotEmpty) {
        _filteredSuggestions = _autocompletePool
            .where((s) => s.toLowerCase().contains(text.toLowerCase()))
            .toList();
        _showSuggestions = _filteredSuggestions.isNotEmpty && _searchFocusNode.hasFocus;
      } else {
        _filteredSuggestions = [];
        _showSuggestions = false;
      }
    });
  }

  void _onSearchFocusChanged() {
    setState(() {
      _showSuggestions = _searchFocusNode.hasFocus && _searchController.text.isNotEmpty;
    });
  }

  void _selectSuggestion(String suggestion) {
    _searchController.text = suggestion;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: suggestion.length),
    );
    setState(() {
      _showSuggestions = false;
    });
    _searchFocusNode.unfocus();
  }

  void _handlePropertyTap(BuildContext context, PropertyModel property) {
    context.read<RecentlyViewedProvider>().addProperty(property.id);
    context.push('/property/${property.id}');
  }

  void _handleSaveToggle(BuildContext context, SavedPropertiesProvider savedProvider, PropertyModel property) {
    final isSaved = savedProvider.isSaved(property.id);
    savedProvider.toggleSave(property.id);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isSaved ? 'Removed from favorites' : 'Added to favorites'),
        backgroundColor: isSaved ? const Color(0xff6B7280) : const Color(0xff10B981),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showFilterModal(BuildContext context, SearchFiltersProvider filterProvider, String type) {
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
        options = filterProvider.getDistrictsForDivision(filterProvider.division);
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      ),
      builder: (context) {
        String localSelected = currentVal;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Select $type',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff1F2937)),
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: options.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.0),
                              child: Text('No options available.', style: TextStyle(color: Color(0xff6B7280))),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (context, index) {
                                final opt = options[index];
                                return RadioListTile<String>(
                                  title: Text(opt, style: const TextStyle(fontSize: 14, color: Color(0xff1F2937))),
                                  value: opt,
                                  groupValue: localSelected,
                                  activeColor: const Color(0xff1E40AF),
                                  onChanged: (val) {
                                    setModalState(() {
                                      localSelected = val ?? '';
                                    });
                                  },
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffF59E0B), // CTA Orange
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        if (localSelected.isNotEmpty) {
                          onSelect(localSelected);
                        }
                        Navigator.pop(context);
                      },
                      child: const Text('Apply Filter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    final propertyProvider = context.watch<PropertyProvider>();
    final savedProvider = context.watch<SavedPropertiesProvider>();
    final filterProvider = context.watch<SearchFiltersProvider>();

    final allListings = propertyProvider.properties;

    // Apply filtering logic based on SearchFiltersProvider and text query
    var filteredListings = allListings.where((p) {
      // 1. Text search matches
      final matchesSearchQuery = _searchQuery.isEmpty ||
          p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.area.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.address.toLowerCase().contains(_searchQuery.toLowerCase());

      // 2. Division filter matches
      // Gazipur is Gazipur district, Gazipur Sadar. Dhaka covers Gulshan, Banani, Mirpur, Uttara, Dhanmondi
      final isGazipur = p.id == 'p11';
      final matchesDivision = filterProvider.division.isEmpty ||
          (filterProvider.division == 'Dhaka' && !isGazipur) ||
          (filterProvider.division == 'Khulna' && false); // no Khulna mocks

      // 3. District filter matches
      final matchesDistrict = filterProvider.district.isEmpty ||
          (filterProvider.district == 'Dhaka' && !isGazipur) ||
          (filterProvider.district == 'Gazipur' && isGazipur);

      // 4. Thana filter matches
      final matchesThana = filterProvider.thana.isEmpty ||
          p.area.toLowerCase().contains(filterProvider.thana.toLowerCase()) ||
          p.address.toLowerCase().contains(filterProvider.thana.toLowerCase());

      // 5. Area filter matches
      final matchesArea = filterProvider.area.isEmpty ||
          p.area.toLowerCase().contains(filterProvider.area.toLowerCase()) ||
          p.address.toLowerCase().contains(filterProvider.area.toLowerCase());

      return matchesSearchQuery && matchesDivision && matchesDistrict && matchesThana && matchesArea;
    }).toList();

    // Apply Sorting logic
    if (filterProvider.sortBy == 'Price Low-High') {
      filteredListings.sort((a, b) => a.price.compareTo(b.price));
    } else if (filterProvider.sortBy == 'Price High-Low') {
      filteredListings.sort((a, b) => b.price.compareTo(a.price));
    } else if (filterProvider.sortBy == 'Rating') {
      // Sort mock by ID lengths
      filteredListings.sort((a, b) => b.id.compareTo(a.id));
    }

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
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xff1E40AF), size: 24),
              onPressed: () => context.go('/home'),
            ),
            title: const Text(
              'DwellWise',
              style: TextStyle(
                color: Color(0xff1E40AF),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined, color: Color(0xff1E40AF), size: 24),
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
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. SEARCH HEADER SECTION (Sticky Search Bar)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _searchFocusNode.hasFocus ? const Color(0xff1E40AF) : const Color(0xffD1D5DB),
                      width: _searchFocusNode.hasFocus ? 1.5 : 1.0,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Color(0xff6B7280)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          style: const TextStyle(color: Color(0xff1F2937), fontSize: 15),
                          decoration: const InputDecoration(
                            hintText: 'Search neighborhood or city...',
                            hintStyle: TextStyle(color: Color(0xff9CA3AF)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const Icon(Icons.location_on, color: Color(0xff6B7280)),
                    ],
                  ),
                ),
              ),

              // 2. FILTER BUTTONS SECTION (Division, District, Thana, Area)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'FILTERS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff6B7280),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            filterProvider.clearAll();
                            _searchController.clear();
                          },
                          child: const Text(
                            'Clear All',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xff1E40AF),
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
                            label: filterProvider.division.isEmpty
                                ? 'Division ▼'
                                : '${filterProvider.division} ▼',
                            isActive: filterProvider.division.isNotEmpty,
                            onTap: () => _showFilterModal(context, filterProvider, 'Division'),
                          ),
                          _buildFilterButton(
                            label: filterProvider.district.isEmpty
                                ? 'District ▼'
                                : '${filterProvider.district} ▼',
                            isActive: filterProvider.district.isNotEmpty,
                            onTap: () => _showFilterModal(context, filterProvider, 'District'),
                          ),
                          _buildFilterButton(
                            label: filterProvider.thana.isEmpty
                                ? 'Thana ▼'
                                : '${filterProvider.thana} ▼',
                            isActive: filterProvider.thana.isNotEmpty,
                            onTap: () => _showFilterModal(context, filterProvider, 'Thana'),
                          ),
                          _buildFilterButton(
                            label: filterProvider.area.isEmpty
                                ? 'Area ▼'
                                : '${filterProvider.area} ▼',
                            isActive: filterProvider.area.isNotEmpty,
                            onTap: () => _showFilterModal(context, filterProvider, 'Area'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),

              // Divider lines
              Container(height: 1, color: const Color(0xffD1D5DB)),

              // RESULTS HEADER (Count and Sort dropdown)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Showing ${filteredListings.length} results in Dhaka',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xff6B7280),
                      ),
                    ),
                    DropdownButton<String>(
                      value: filterProvider.sortBy == 'Newest' ? 'Sort: Newest ▼' : 'Sort: ${filterProvider.sortBy} ▼',
                      underline: const SizedBox.shrink(),
                      icon: const SizedBox.shrink(),
                      style: const TextStyle(
                        color: Color(0xff1E40AF),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      onChanged: (val) {
                        if (val != null) {
                          final cleanedSort = val.replaceAll('Sort: ', '').replaceAll(' ▼', '');
                          filterProvider.setSortBy(cleanedSort);
                        }
                      },
                      items: const [
                        DropdownMenuItem(value: 'Sort: Newest ▼', child: Text('Sort: Newest')),
                        DropdownMenuItem(value: 'Sort: Price Low-High ▼', child: Text('Price: Low-High')),
                        DropdownMenuItem(value: 'Sort: Price High-Low ▼', child: Text('Price: High-Low')),
                        DropdownMenuItem(value: 'Sort: Rating ▼', child: Text('Sort: Rating')),
                      ],
                    ),
                  ],
                ),
              ),

              // RESULTS LIST VIEW
              Expanded(
                child: filteredListings.isEmpty
                    ? const Center(
                        child: Text(
                          'No properties found matching the criteria.',
                          style: TextStyle(color: Color(0xff6B7280)),
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: filteredListings.length,
                        itemBuilder: (context, index) {
                          final property = filteredListings[index];
                          final isSaved = savedProvider.isSaved(property.id);

                          return PropertyCard(
                            property: property,
                            showDetails: true,
                            isSaved: isSaved,
                            onTap: () => _handlePropertyTap(context, property),
                            onSaveTap: () => _handleSaveToggle(context, savedProvider, property),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 120), // nav bar bottom clearance
            ],
          ),

          // Autocomplete suggestions floating panel overlay
          if (_showSuggestions)
            Positioned(
              top: 64, // below sticky search header box
              left: 16,
              right: 16,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Container(
                  color: Colors.white,
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredSuggestions.length,
                    itemBuilder: (context, index) {
                      final sug = _filteredSuggestions[index];
                      return ListTile(
                        leading: const Icon(Icons.location_city, size: 18, color: Color(0xff6B7280)),
                        title: Text(sug, style: const TextStyle(fontSize: 14, color: Color(0xff1F2937))),
                        onTap: () => _selectSuggestion(sug),
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 1),
    );
  }

  Widget _buildFilterButton({
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
            color: isActive ? const Color(0xffEFF6FF) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? const Color(0xff1E40AF) : const Color(0xffD1D5DB),
              width: isActive ? 1.5 : 1.0,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xff1E40AF) : const Color(0xff1F2937),
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
