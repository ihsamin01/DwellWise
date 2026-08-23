import 'package:flutter/material.dart';

import '../models/property_model.dart';
import '../services/supabase_service.dart';

/// Provider managing the user's saved / favourite properties.
class SavedPropertiesProvider with ChangeNotifier {
  final SupabaseService _dbService = SupabaseService();

  final Set<String> _savedIds = {};
  final List<PropertyModel> _savedProperties = [];

  Set<String> get savedIds => _savedIds;

  /// Saved properties, newest save first.
  List<PropertyModel> get savedProperties =>
      List.unmodifiable(_savedProperties);

  bool isSaved(String id) => _savedIds.contains(id);

  /// Loads the signed-in user's saves from the database.
  Future<void> loadSaved() async {
    try {
      final saved = await _dbService.getSavedProperties();
      _savedIds
        ..clear()
        ..addAll(saved.map((p) => p.id));
      _savedProperties
        ..clear()
        ..addAll(saved);
      notifyListeners();
    } catch (_) {
      // Keep what is already listed.
    }
  }

  /// [property] lets the list update without waiting for a refetch.
  void toggleSave(String id, {PropertyModel? property}) {
    if (_savedIds.contains(id)) {
      unsave(id);
    } else {
      save(id, property: property);
    }
  }

  void save(String id, {PropertyModel? property}) {
    if (!_savedIds.add(id)) return;

    if (property != null && !_savedProperties.any((p) => p.id == id)) {
      // Newest save first, matching the order the database returns.
      _savedProperties.insert(0, property);
    }
    notifyListeners();

    _dbService.saveProperty(id).then((_) {
      // Nothing came back to insert optimistically, so pick the row up now.
      if (property == null) loadSaved();
    });
  }

  void unsave(String id) {
    if (!_savedIds.remove(id)) return;
    _savedProperties.removeWhere((p) => p.id == id);
    notifyListeners();
    _dbService.unsaveProperty(id);
  }

  /// Clears local state on logout so the next signed-in user (or guest).
  void clear() {
    _savedIds.clear();
    _savedProperties.clear();
    notifyListeners();
  }
}
