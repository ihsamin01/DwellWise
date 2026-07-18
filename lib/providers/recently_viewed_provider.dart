import 'package:flutter/material.dart';

/// Provider managing the user's recently viewed property IDs history.
class RecentlyViewedProvider with ChangeNotifier {
  final List<String> _recentlyViewedIds = [];

  List<String> get recentlyViewedIds => _recentlyViewedIds;

  void addProperty(String id) {
    // Remove if already exists to push to front
    _recentlyViewedIds.remove(id);
    // Insert at beginning
    _recentlyViewedIds.insert(0, id);
    // Limit to max 5 items
    if (_recentlyViewedIds.length > 5) {
      _recentlyViewedIds.removeLast();
    }
    notifyListeners();
  }

  void clear() {
    _recentlyViewedIds.clear();
    notifyListeners();
  }
}
