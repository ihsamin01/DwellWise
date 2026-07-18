import 'package:flutter/material.dart';

/// Provider handling hierarchical location filter values (Division, District, Thana, Area) and sorting.
class SearchFiltersProvider with ChangeNotifier {
  String _division = '';
  String _district = '';
  String _thana = '';
  String _area = '';
  String _sortBy = 'Newest';

  String get division => _division;
  String get district => _district;
  String get thana => _thana;
  String get area => _area;
  String get sortBy => _sortBy;

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

  void setSortBy(String val) {
    _sortBy = val;
    notifyListeners();
  }

  void clearAll() {
    _division = '';
    _district = '';
    _thana = '';
    _area = '';
    _sortBy = 'Newest';
    notifyListeners();
  }

  // Hierarchical mock data structures
  final List<String> divisionsList = ['Dhaka', 'Chattogram', 'Khulna', 'Rajshahi'];

  List<String> getDistrictsForDivision(String div) {
    switch (div) {
      case 'Dhaka':
        return ['Dhaka', 'Gazipur', 'Narayanganj'];
      case 'Chattogram':
        return ['Chittagong', 'Cox\'s Bazar', 'Feni'];
      case 'Khulna':
        return ['Khulna', 'Jessore'];
      case 'Rajshahi':
        return ['Rajshahi', 'Bogra'];
      default:
        return [];
    }
  }

  List<String> getThanasForDistrict(String dist) {
    switch (dist) {
      case 'Dhaka':
        return ['Dhanmondi', 'Gulshan', 'Banani', 'Mirpur', 'Uttara'];
      case 'Chittagong':
        return ['Double Mooring', 'Panchlaish', 'Halishahar'];
      case 'Khulna':
        return ['Sadar', 'Sonadanga'];
      case 'Rajshahi':
        return ['Boalia', 'Rajput'];
      default:
        return [];
    }
  }

  List<String> getAreasForThana(String th) {
    switch (th) {
      case 'Gulshan':
        return ['Gulshan 1', 'Gulshan 2', 'Gulshan Avenue'];
      case 'Banani':
        return ['Banani Block A', 'Banani Block H', 'Banani Block E'];
      case 'Dhanmondi':
        return ['Dhanmondi Lake', 'Dhanmondi Road 27', 'Dhanmondi Road 8A'];
      case 'Uttara':
        return ['Sector 4', 'Sector 11', 'Sector 13'];
      case 'Mirpur':
        return ['Mirpur 1', 'Mirpur 10', 'Mirpur DOHS'];
      default:
        return ['$th Area 1', '$th Area 2'];
    }
  }
}
