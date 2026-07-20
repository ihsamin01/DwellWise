import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_colors.dart';
import '../../config/app_strings.dart';
import '../../data/bd_locations.dart';
import '../../models/property_model.dart';
import '../../providers/property_provider.dart';
import '../../utils/map_launcher.dart';

/// Multi-step "Rent your property" flow: Basic → Location → Price → Detailed.
/// On finish it creates a [PropertyModel] owned by the current user, which then
/// appears under "My properties".
class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  static const _types = ['Family', 'Bachelor', 'Office room', 'Sublet', 'Hostel'];
  static const _counts = [1, 2, 3, 4, 5, 6];
  static const _priceFors = ['Monthly', 'Weekly', 'Daily'];
  static const _bills = ['Electricity bill', 'Gas bill', 'Water bill', 'Internet', 'Service charge'];
  static const _features = ['LIFT', 'GARAGE', 'CCTV', 'GAS'];

  // Basic information
  final _titleController = TextEditingController();
  String? _availableMonth;
  String? _type;
  int? _bedrooms;
  int? _bathrooms;
  int? _balcony;

  // Location information
  String? _division;
  String? _district;
  String? _area;
  final _sectorController = TextEditingController();
  final _roadController = TextEditingController();
  final _houseController = TextEditingController();
  final _shortAddressController = TextEditingController();

  // Price
  final _priceController = TextEditingController();
  String _priceFor = 'Monthly';
  final Set<String> _includedBills = {};

  // Detailed
  final Set<String> _selectedFeatures = {};
  final _descriptionController = TextEditingController();
  int _pictureCount = 0;

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _sectorController.dispose();
    _roadController.dispose();
    _houseController.dispose();
    _shortAddressController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _snack(String key) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.tr(context, key))),
    );
  }

  /// Composes a human-readable address from the location fields.
  String _composedAddress() {
    final parts = <String>[
      if (_houseController.text.trim().isNotEmpty) 'House ${_houseController.text.trim()}',
      if (_roadController.text.trim().isNotEmpty) 'Road ${_roadController.text.trim()}',
      if (_sectorController.text.trim().isNotEmpty) 'Sector ${_sectorController.text.trim()}',
      if (_shortAddressController.text.trim().isNotEmpty) _shortAddressController.text.trim(),
      if (_area != null) _area!,
      if (_district != null) _district!,
      if (_division != null) _division!,
    ];
    return parts.join(', ');
  }

  bool _validateBasic() {
    if (_titleController.text.trim().isEmpty) {
      _snack('ap_v_title');
      return false;
    }
    if (_availableMonth == null || _type == null ||
        _bedrooms == null || _bathrooms == null || _balcony == null) {
      _snack('ap_v_basic');
      return false;
    }
    return true;
  }

  bool _validateLocation() {
    if (_division == null || _district == null || _area == null) {
      _snack('ap_v_location');
      return false;
    }
    return true;
  }

  bool _validatePrice() {
    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) {
      _snack('ap_v_price');
      return false;
    }
    return true;
  }

  void _next() {
    final index = _tabController.index;
    if (index == 0 && !_validateBasic()) return;
    if (index == 1 && !_validateLocation()) return;
    if (index == 2 && !_validatePrice()) return;
    if (index < 3) {
      _tabController.animateTo(index + 1);
    } else {
      _submit();
    }
  }

  Future<void> _submit() async {
    if (!_validateBasic()) {
      _tabController.animateTo(0);
      return;
    }
    if (!_validateLocation()) {
      _tabController.animateTo(1);
      return;
    }
    if (!_validatePrice()) {
      _tabController.animateTo(2);
      return;
    }

    setState(() => _submitting = true);

    final provider = context.read<PropertyProvider>();
    final property = PropertyModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      priceFor: _priceFor,
      propertyType: _type!,
      area: _area!,
      address: _composedAddress(),
      latitude: 0,
      longitude: 0,
      beds: _bedrooms!,
      baths: _bathrooms!,
      balcony: _balcony!,
      sizeSqFt: 0,
      availableFrom: _availableMonth!,
      includedBills: _includedBills.toList(),
      imageUrls: const [],
      isVerified: false,
      ownerId: PropertyProvider.currentUserId,
      facilities: _selectedFeatures.toList(),
      createdAt: DateTime.now(),
    );

    final ok = await provider.addProperty(property);
    if (!mounted) return;
    setState(() => _submitting = false);

    if (ok) {
      _snack('ap_posted');
      context.go('/profile/my-properties');
    } else {
      _snack('ap_post_failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isLast = _tabController.index == 3;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(AppStrings.t(context, 'ap_title')),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          onTap: (_) => setState(() {}),
          // Explicit white labels so the selected tab stays visible on the
          // blue app bar (the default label colour would blend into it).
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontSize: 13),
          tabs: [
            Tab(icon: const Icon(Icons.info_outline, size: 18), text: AppStrings.t(context, 'ap_tab_basic')),
            Tab(icon: const Icon(Icons.location_city, size: 18), text: AppStrings.t(context, 'ap_tab_location')),
            Tab(icon: const Icon(Icons.payments_outlined, size: 18), text: AppStrings.t(context, 'ap_tab_price')),
            Tab(icon: const Icon(Icons.notes_outlined, size: 18), text: AppStrings.t(context, 'ap_tab_details')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildBasicTab(colors),
          _buildLocationTab(colors),
          _buildPriceTab(colors),
          _buildDetailedTab(colors),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (_tabController.index > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(
                        () => _tabController.animateTo(_tabController.index - 1)),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: Text(AppStrings.t(context, 'back')),
                  ),
                ),
              if (_tabController.index > 0) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _next,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text(AppStrings.t(context, isLast ? 'ap_post' : 'next')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 1: Basic information
  // ---------------------------------------------------------------------------
  Widget _buildBasicTab(AppColors colors) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _label(AppStrings.t(context, 'ap_prop_title'), colors, required: true),
        TextField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: AppStrings.t(context, 'ap_prop_title_hint'),
            prefixIcon: const Icon(Icons.title),
          ),
        ),
        const SizedBox(height: 18),
        _label(AppStrings.t(context, 'ap_available'), colors, required: true),
        _dropdown<String>(
          value: _availableMonth,
          hint: AppStrings.t(context, 'ap_select_month'),
          icon: Icons.event_available_outlined,
          items: _months,
          labelOf: (m) => AppStrings.t(context, 'month_$m'),
          onChanged: (v) => setState(() => _availableMonth = v),
        ),
        const SizedBox(height: 18),
        _label(AppStrings.t(context, 'ap_type'), colors, required: true),
        _dropdown<String>(
          value: _type,
          hint: AppStrings.t(context, 'ap_select_type'),
          icon: Icons.home_work_outlined,
          items: _types,
          labelOf: (t) => AppStrings.t(context, 'type_$t'),
          onChanged: (v) => setState(() => _type = v),
        ),
        const SizedBox(height: 18),
        _label(AppStrings.t(context, 'ap_bedrooms'), colors, required: true),
        _dropdown<int>(
          value: _bedrooms,
          hint: AppStrings.t(context, 'ap_select_bedrooms'),
          icon: Icons.bed_outlined,
          items: _counts,
          labelOf: (c) => AppStrings.digits(context, '$c'),
          onChanged: (v) => setState(() => _bedrooms = v),
        ),
        const SizedBox(height: 18),
        _label(AppStrings.t(context, 'ap_bathrooms'), colors, required: true),
        _dropdown<int>(
          value: _bathrooms,
          hint: AppStrings.t(context, 'ap_select_bathrooms'),
          icon: Icons.bathtub_outlined,
          items: _counts,
          labelOf: (c) => AppStrings.digits(context, '$c'),
          onChanged: (v) => setState(() => _bathrooms = v),
        ),
        const SizedBox(height: 18),
        _label(AppStrings.t(context, 'ap_balcony'), colors, required: true),
        _dropdown<int>(
          value: _balcony,
          hint: AppStrings.t(context, 'ap_select_balcony'),
          icon: Icons.balcony_outlined,
          items: _counts,
          labelOf: (c) => AppStrings.digits(context, '$c'),
          onChanged: (v) => setState(() => _balcony = v),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 2: Location information
  // ---------------------------------------------------------------------------
  Widget _buildLocationTab(AppColors colors) {
    final districts = _division != null ? BdLocations.districtsOf(_division!) : <String>[];
    final areas = (_division != null && _district != null)
        ? BdLocations.thanasOf(_division!, _district!)
        : <String>[];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _label(AppStrings.t(context, 'ap_division'), colors, required: true),
        _dropdown<String>(
          value: _division,
          hint: AppStrings.t(context, 'ap_select_division'),
          icon: Icons.map_outlined,
          items: BdLocations.divisions,
          labelOf: (v) => v,
          onChanged: (v) => setState(() {
            _division = v;
            _district = null;
            _area = null;
          }),
        ),
        const SizedBox(height: 18),
        _label(AppStrings.t(context, 'ap_district'), colors, required: true),
        _dropdown<String>(
          value: _district,
          hint: _division == null
              ? AppStrings.t(context, 'ap_select_division_first')
              : AppStrings.t(context, 'ap_select_district'),
          icon: Icons.location_city_outlined,
          items: districts,
          labelOf: (v) => v,
          onChanged: (v) => setState(() {
            _district = v;
            _area = null;
          }),
        ),
        const SizedBox(height: 18),
        _label(AppStrings.t(context, 'ap_area'), colors, required: true),
        _dropdown<String>(
          value: _area,
          hint: _district == null
              ? AppStrings.t(context, 'ap_select_district_first')
              : AppStrings.t(context, 'ap_select_area'),
          icon: Icons.place_outlined,
          items: areas,
          labelOf: (v) => v,
          onChanged: (v) => setState(() => _area = v),
        ),
        const SizedBox(height: 18),
        _label(AppStrings.t(context, 'ap_sector'), colors, optional: true),
        _textField(_sectorController, AppStrings.t(context, 'ap_sector_hint'), Icons.numbers,
            keyboardType: TextInputType.number),
        const SizedBox(height: 18),
        _label(AppStrings.t(context, 'ap_road'), colors, optional: true),
        _textField(_roadController, AppStrings.t(context, 'ap_road_hint'), Icons.add_road_outlined,
            keyboardType: TextInputType.number),
        const SizedBox(height: 18),
        _label(AppStrings.t(context, 'ap_house'), colors, optional: true),
        _textField(_houseController, AppStrings.t(context, 'ap_house_hint'), Icons.home_outlined,
            keyboardType: TextInputType.number),
        const SizedBox(height: 18),
        _label(AppStrings.t(context, 'ap_short_address'), colors, optional: true),
        _textField(_shortAddressController, AppStrings.t(context, 'ap_short_address_hint'),
            Icons.badge_outlined),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 3: Price
  // ---------------------------------------------------------------------------
  Widget _buildPriceTab(AppColors colors) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _label(AppStrings.t(context, 'ap_price'), colors, required: true),
        _textField(_priceController, AppStrings.t(context, 'ap_price_hint'), Icons.payments_outlined,
            keyboardType: TextInputType.number),
        const SizedBox(height: 18),
        _label(AppStrings.t(context, 'ap_price_for'), colors, required: true),
        _dropdown<String>(
          value: _priceFor,
          hint: AppStrings.t(context, 'ap_select_period'),
          icon: Icons.schedule_outlined,
          items: _priceFors,
          labelOf: (p) => AppStrings.t(context, 'period_$p'),
          onChanged: (v) => setState(() => _priceFor = v ?? 'Monthly'),
        ),
        const SizedBox(height: 22),
        _label(AppStrings.t(context, 'ap_included'), colors),
        const SizedBox(height: 4),
        Text(AppStrings.t(context, 'ap_included_desc'),
            style: TextStyle(fontSize: 12.5, color: colors.textSecondary)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _bills.map((bill) {
            final selected = _includedBills.contains(bill);
            return _choiceChip(
              label: AppStrings.t(context, 'bill_$bill'),
              selected: selected,
              colors: colors,
              onTap: () => setState(() {
                selected ? _includedBills.remove(bill) : _includedBills.add(bill);
              }),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 4: Detailed information (optional)
  // ---------------------------------------------------------------------------
  Widget _buildDetailedTab(AppColors colors) {
    final composed = _composedAddress();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _label(AppStrings.t(context, 'ap_features'), colors),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _features.map((feature) {
            final selected = _selectedFeatures.contains(feature);
            return _choiceChip(
              label: AppStrings.t(context, 'feat_$feature'),
              selected: selected,
              colors: colors,
              onTap: () => setState(() {
                selected ? _selectedFeatures.remove(feature) : _selectedFeatures.add(feature);
              }),
            );
          }).toList(),
        ),
        const SizedBox(height: 22),
        _label(AppStrings.t(context, 'ap_description'), colors),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: AppStrings.t(context, 'ap_description_hint'),
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 22),
        _label(AppStrings.t(context, 'ap_picture'), colors),
        const SizedBox(height: 8),
        Row(
          children: [
            InkWell(
              onTap: () => setState(() => _pictureCount++),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.border),
                ),
                child: Icon(Icons.add_photo_alternate_outlined,
                    size: 32, color: colors.textSecondary),
              ),
            ),
            const SizedBox(width: 12),
            if (_pictureCount > 0)
              Text(
                  '${AppStrings.digits(context, '$_pictureCount')} ${AppStrings.t(context, _pictureCount > 1 ? 'ap_photos_added' : 'ap_photo_added')}',
                  style: TextStyle(color: colors.textSecondary)),
          ],
        ),
        const SizedBox(height: 22),
        _label(AppStrings.t(context, 'ap_mark_maps'), colors),
        const SizedBox(height: 8),
        _MapPreview(address: composed, colors: colors),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Shared field builders
  // ---------------------------------------------------------------------------
  Widget _label(String text, AppColors colors,
      {bool required = false, bool optional = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          RichText(
            text: TextSpan(
              text: text,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: colors.textPrimary),
              children: [
                if (required)
                  const TextSpan(text: ' *', style: TextStyle(color: Color(0xffDC2626))),
              ],
            ),
          ),
          if (optional)
            Text('  ${AppStrings.t(context, 'optional')}',
                style: TextStyle(fontSize: 12, color: colors.textSecondary)),
        ],
      ),
    );
  }

  Widget _textField(TextEditingController controller, String hint, IconData icon,
      {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: keyboardType == TextInputType.number
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon)),
    );
  }

  Widget _dropdown<T>({
    required T? value,
    required String hint,
    required IconData icon,
    required List<T> items,
    required String Function(T) labelOf,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(prefixIcon: Icon(icon)),
      hint: Text(hint),
      items: items
          .map((item) => DropdownMenuItem<T>(value: item, child: Text(labelOf(item))))
          .toList(),
      onChanged: items.isEmpty ? null : onChanged,
    );
  }

  Widget _choiceChip({
    required String label,
    required bool selected,
    required AppColors colors,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? colors.primary.withOpacity(0.14) : colors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: selected ? colors.primary : colors.border, width: selected ? 1.5 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              Icon(Icons.check, size: 16, color: colors.primary),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? colors.primary : colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Address preview card + "Open in Google Maps" button. This is the key-free
/// map experience: it launches Google Maps centred on the typed address so the
/// user doesn't have to scroll around to find the location.
class _MapPreview extends StatelessWidget {
  final String address;
  final AppColors colors;
  const _MapPreview({required this.address, required this.colors});

  @override
  Widget build(BuildContext context) {
    final hasAddress = address.trim().isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: colors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hasAddress ? address : AppStrings.t(context, 'ap_map_hint'),
                  style: TextStyle(
                    fontSize: 13.5,
                    color: hasAddress ? colors.textPrimary : colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: hasAddress
                  ? () async {
                      final ok = await MapLauncher.openAddress(address);
                      if (!ok && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(AppStrings.tr(context, 'ap_maps_failed'))),
                        );
                      }
                    }
                  : null,
              icon: const Icon(Icons.map_outlined, size: 18),
              label: Text(AppStrings.t(context, 'ap_open_maps')),
            ),
          ),
        ],
      ),
    );
  }
}
