import 'package:flutter/material.dart';
import '../data/bd_locations.dart';

/// Provider handling hierarchical location filter values (Division, District,
/// Thana, Area) backed by the full Bangladesh dataset in [BdLocations],
/// plus result sorting.
class SearchFiltersProvider with ChangeNotifier {
  String _division = '';
  String _district = '';
  String _thana = '';
  String _area = '';
  String _type = '';
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
  String get sortBy => _sortBy;

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
