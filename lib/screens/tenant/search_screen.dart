import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_colors.dart';
import '../../providers/search_filters_provider.dart';
import '../../widgets/bottom_navigation.dart';

/// Tenant Search Screen: hierarchical Division > District > Thana > Area
/// selection plus a property Type filter. Pressing Search opens a dedicated
/// results page — this screen only holds the compact filter inputs.
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
  void _runSearch(BuildContext context, SearchFiltersProvider filterProvider) {
    if (!filterProvider.hasSelection) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least a Division first')),
      );
      return;
    }
    context.push('/search-results');
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
      case 'Type':
        options = SearchFiltersProvider.propertyTypes;
        currentVal = filterProvider.type;
        onSelect = (val) => filterProvider.setType(val);
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
    final filterProvider = context.watch<SearchFiltersProvider>();
    final selectionPath = filterProvider.selectionPath;

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

          // 2. FILTER BUTTONS SECTION (Division, District, Thana, Area, Type)
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
                      onTap: () => filterProvider.clearAll(),
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
                      _buildFilterButton(
                        colors: colors,
                        label: filterProvider.type.isEmpty
                            ? 'Type ▼'
                            : '${filterProvider.type} ▼',
                        isActive: filterProvider.type.isNotEmpty,
                        onTap: () =>
                            _showFilterModal(context, filterProvider, 'Type'),
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

          // 4. INSTRUCTION AREA — results now open on a dedicated page
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.travel_explore, size: 56, color: colors.border),
                  const SizedBox(height: 14),
                  Text(
                    'Select location & type, then press Search',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Division > District > Thana > Area  ·  Type',
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
