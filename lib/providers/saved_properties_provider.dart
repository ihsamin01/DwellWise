import 'package:flutter/material.dart';

import '../models/property_model.dart';
import '../services/supabase_service.dart';

/// Provider managing the user's saved / favourite properties.
///
/// Backed by the `saved_properties` table, and the saved properties themselves
/// are held here rather than looked up in the home feed. The feed only holds a
/// slice of the catalogue, so resolving saves against it made a saved property
/// disappear as soon as it fell out of that slice — the list looked like it
/// had emptied itself even though every row was still in the database.
class SavedPropertiesProvider with ChangeNotifier {
  final SupabaseService _dbService = SupabaseService();

  final Set<String> _savedIds = {};
  final List<PropertyModel> _savedProperties = [];

  Set<String> get savedIds => _savedIds;

  /// Saved properties, newest save first.
  List<PropertyModel> get savedProperties =>
      List.unmodifiable(_savedProperties);

  bool isSaved(String id) => _savedIds.contains(id);

  /// Loads the signed-in user's saves from the database. Called when the
  /// tenant tabs mount, so favourites are restored right after login.
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
      // Keep what is already listed. A failed request is not an empty list,
      // and clearing here is what used to wipe the screen on a dropped
      // connection.
    }
  }

  /// [property] lets the list update without waiting for a refetch. Callers
  /// always have the model in hand, since they are drawing it.
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

  /// Clears local state on logout so the next signed-in user (or guest)
  /// doesn't briefly see the previous user's saved list. The rows stay in the
  /// database and come back on the next [loadSaved].
  void clear() {
    _savedIds.clear();
    _savedProperties.clear();
    notifyListeners();
  }
}
