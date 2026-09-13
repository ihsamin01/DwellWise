import 'package:flutter/material.dart';
import '../data/bd_locations.dart';
import '../widgets/property_card.dart' show formatWithCommas;

/// Provider handling hierarchical location filter values (Division, District,
/// Thana, Area) backed by the full Bangladesh dataset in [BdLocations],
/// plus result sorting.
class SearchFiltersProvider with ChangeNotifier {
  String _division = '';
  String _district = '';
  String _thana = '';
  String _area = '';
  String _type = '';
  double? _minPrice;
  double? _maxPrice;
  String _sortBy = 'Newest';

  /// User-facing property categories offered by the Type filter.
  static const List<String> propertyTypes = [
    'Family', 'Bachelor', 'Office room', 'Sublet', 'Hostel',
  ];

  String get division => _division;
  String get district => _district;
  String get thana => _thana;
  String get area => _area;
  String get type => _type;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;
  String get sortBy => _sortBy;

  bool get hasPriceFilter => _minPrice != null || _maxPrice != null;

  /// e.g. "৳10,000 - ৳25,000", "৳10,000+", "Up to ৳25,000". Empty when
  /// neither bound is set.
  String get priceRangeLabel {
    if (_minPrice == null && _maxPrice == null) return '';
    if (_minPrice != null && _maxPrice != null) {
      return '৳${formatWithCommas(_minPrice!)} - ৳${formatWithCommas(_maxPrice!)}';
    }
    if (_minPrice != null) return '৳${formatWithCommas(_minPrice!)}+';
    return 'Up to ৳${formatWithCommas(_maxPrice!)}';
  }

  /// Human-readable breadcrumb of the current selection, most specific last.
  /// e.g. "Dhaka > Dhaka > Pallabi > Kalshi". Empty when nothing selected.
  String get selectionPath {
    final parts = <String>[
      if (_division.isNotEmpty) _division,
      if (_district.isNotEmpty) _district,
      if (_thana.isNotEmpty) _thana,
      if (_area.isNotEmpty) _area,
    ];
    return parts.join(' > ');
  }

  bool get hasSelection => _division.isNotEmpty;

  void setDivision(String val) {
    _division = val;
    // reset subordinate filters
    _district = '';
    _thana = '';
    _area = '';
    notifyListeners();
  }

  void setDistrict(String val) {
    _district = val;
    _thana = '';
    _area = '';
    notifyListeners();
  }

  void setThana(String val) {
    _thana = val;
    _area = '';
    notifyListeners();
  }

  void setArea(String val) {
    _area = val;
    notifyListeners();
  }

  void setType(String val) {
    _type = val;
    notifyListeners();
  }

  /// Either bound may be null to leave that side open-ended.
  void setPriceRange(double? min, double? max) {
    _minPrice = min;
    _maxPrice = max;
    notifyListeners();
  }

  void clearPriceRange() {
    _minPrice = null;
    _maxPrice = null;
    notifyListeners();
  }

  void setSortBy(String val) {
    _sortBy = val;
    notifyListeners();
  }

  void clearAll() {
    _division = '';
    _district = '';
    _thana = '';
    _area = '';
    _type = '';
    _minPrice = null;
    _maxPrice = null;
    _sortBy = 'Newest';
    notifyListeners();
  }

  // ---- Dataset-backed option lists ----

  List<String> get divisionsList => BdLocations.divisions;

  List<String> getDistrictsForDivision(String div) =>
      BdLocations.districtsOf(div);

  List<String> getThanasForDistrict(String dist) =>
      BdLocations.thanasOf(_division, dist);

  List<String> getAreasForThana(String th) =>
      BdLocations.areasForThana(_district, th);
}
