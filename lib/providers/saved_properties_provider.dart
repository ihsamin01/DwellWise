import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

/// Provider managing the list of saved/favorite property IDs. Backed by the
/// `saved_properties` table so favorites survive logging out and back in, or
/// reinstalling the app.
class SavedPropertiesProvider with ChangeNotifier {
  final SupabaseService _dbService = SupabaseService();
  final Set<String> _savedIds = {};

  Set<String> get savedIds => _savedIds;

  bool isSaved(String id) => _savedIds.contains(id);

  /// Loads the signed-in user's saved property ids from the database. Called
  /// once the tenant tabs mount, so favorites are restored right after login.
  Future<void> loadSavedIds() async {
    final ids = await _dbService.getSavedPropertyIds();
    _savedIds
      ..clear()
      ..addAll(ids);
    notifyListeners();
  }

  void toggleSave(String id) {
    if (_savedIds.contains(id)) {
      unsave(id);
    } else {
      save(id);
    }
  }

  void save(String id) {
    if (_savedIds.add(id)) {
      notifyListeners();
      _dbService.saveProperty(id);
    }
  }

  void unsave(String id) {
    if (_savedIds.remove(id)) {
      notifyListeners();
      _dbService.unsaveProperty(id);
    }
  }

  /// Clears local state on logout so the next signed-in user (or guest)
  /// doesn't briefly see the previous user's saved list.
  void clear() {
    _savedIds.clear();
    notifyListeners();
  }
}
