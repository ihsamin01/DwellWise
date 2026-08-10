import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

/// Provider managing the user's recently viewed property IDs history. Backed
/// by the `recently_viewed` table so history survives logging out and back
/// in, or reinstalling the app.
class RecentlyViewedProvider with ChangeNotifier {
  final SupabaseService _dbService = SupabaseService();
  final List<String> _recentlyViewedIds = [];

  static const int _maxItems = 5;

  List<String> get recentlyViewedIds => _recentlyViewedIds;

  /// Loads the signed-in user's recently viewed ids from the database.
  /// Called once the Home tab mounts, so history is restored right after
  /// login.
  Future<void> loadRecentlyViewedIds() async {
    final ids = await _dbService.getRecentlyViewedIds(limit: _maxItems);
    _recentlyViewedIds
      ..clear()
      ..addAll(ids);
    notifyListeners();
  }

  void addProperty(String id) {
    // Remove if already exists to push to front
    _recentlyViewedIds.remove(id);
    // Insert at beginning
    _recentlyViewedIds.insert(0, id);
    // Limit to max items
    if (_recentlyViewedIds.length > _maxItems) {
      _recentlyViewedIds.removeLast();
    }
    notifyListeners();
    _dbService.recordPropertyView(id);
  }

  /// Clears local state on logout so the next signed-in user (or guest)
  /// doesn't briefly see the previous user's history.
  void clear() {
    _recentlyViewedIds.clear();
    notifyListeners();
  }
}
