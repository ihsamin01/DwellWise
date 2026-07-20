import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_colors.dart';
import '../../models/property_model.dart';
import '../../providers/property_provider.dart';
import '../../providers/saved_properties_provider.dart';
import '../../providers/recently_viewed_provider.dart';
import '../../providers/search_filters_provider.dart';
import '../../services/mock_search_service.dart';
import '../../widgets/property_card.dart';

/// Dedicated results page reached from the Search screen. Shows a compact
/// summary of the selected filters with a sort control, and the matching
/// (dummy) rental listings below.
class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  /// Same sort options as the home feed.
  static const Map<String, String> _sortOptions = {
    'Newest': 'Newest',
    'Price Low-High': 'Price: Low to High',
    'Price High-Low': 'Price: High to Low',
  };

  List<PropertyModel> _base = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _buildResults());
  }

  void _buildResults() {
    final fp = context.read<SearchFiltersProvider>();
    final pp = context.read<PropertyProvider>();

    // 1. Location-generated realistic listings (type-aware).
    final generated = MockSearchService.generate(
      division: fp.division,
      district: fp.district,
      thana: fp.thana,
      area: fp.area,
      type: fp.type,
    );

    // 2. Home-feed posts that genuinely match the most specific locality.
    final locality = (fp.area.isNotEmpty
            ? fp.area
            : fp.thana.isNotEmpty
                ? fp.thana
                : fp.district)
        .toLowerCase();
    var homeMatches = locality.isEmpty
        ? <PropertyModel>[]
        : pp.properties
            .where((p) =>
                p.area.toLowerCase().contains(locality) ||
                p.address.toLowerCase().contains(locality))
            .toList();
    if (fp.type.isNotEmpty) {
      homeMatches =
          homeMatches.where((p) => p.propertyType == fp.type).toList();
    }

    // Register generated posts so details/saved/recently screens resolve them.
    pp.registerSearchResults(generated);

    setState(() => _base = [...homeMatches, ...generated]);
  }

  List<PropertyModel> _sorted(String sortBy) {
    final result = List<PropertyModel>.from(_base);
    switch (sortBy) {
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
        content: Text(isSaved ? 'Removed from favorites' : 'Added to favorites'),
        backgroundColor:
            isSaved ? const Color(0xff6B7280) : const Color(0xff10B981),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final filterProvider = context.watch<SearchFiltersProvider>();
    final savedProvider = context.watch<SavedPropertiesProvider>();

    final results = _sorted(filterProvider.sortBy);

    // Selected filter chips (compact): location parts + type.
    final chips = <String>[
      if (filterProvider.division.isNotEmpty) filterProvider.division,
      if (filterProvider.district.isNotEmpty) filterProvider.district,
      if (filterProvider.thana.isNotEmpty) filterProvider.thana,
      if (filterProvider.area.isNotEmpty) filterProvider.area,
      if (filterProvider.type.isNotEmpty) filterProvider.type,
    ];

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Search Results'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Compact selected-filters header with sort control on the right.
          Container(
            color: colors.surface,
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final c in chips) _chip(colors, c),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${results.length} results found',
                        style: TextStyle(
                            fontSize: 11.5, color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                _sortControl(colors, filterProvider),
              ],
            ),
          ),
          Container(height: 1, color: colors.border),

          // Results
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Text(
                      'No properties found for this selection.',
                      style: TextStyle(color: colors.textSecondary),
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final property = results[index];
                      return PropertyCard(
                        property: property,
                        showDetails: true,
                        showDate: filterProvider.sortBy == 'Newest',
                        isSaved: savedProvider.isSaved(property.id),
                        onTap: () => _handlePropertyTap(context, property),
                        onSaveTap: () =>
                            _handleSaveToggle(context, savedProvider, property),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _chip(AppColors colors, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.primaryTint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.primary.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600, color: colors.primary),
      ),
    );
  }

  Widget _sortControl(AppColors colors, SearchFiltersProvider filterProvider) {
    return PopupMenuButton<String>(
      tooltip: 'Sort listings',
      offset: const Offset(0, 40),
      color: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) => filterProvider.setSortBy(value),
      itemBuilder: (context) => _sortOptions.entries.map((e) {
        final selected = filterProvider.sortBy == e.key;
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
            const SizedBox(width: 2),
            Icon(Icons.keyboard_arrow_down, size: 16, color: colors.primary),
          ],
        ),
      ),
    );
  }
}
