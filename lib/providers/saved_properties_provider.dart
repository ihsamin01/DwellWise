import 'package:flutter/material.dart';

/// Provider managing the list of saved/favorite property IDs.
class SavedPropertiesProvider with ChangeNotifier {
  final Set<String> _savedIds = {};

  Set<String> get savedIds => _savedIds;

  bool isSaved(String id) => _savedIds.contains(id);

  void toggleSave(String id) {
    if (_savedIds.contains(id)) {
      _savedIds.remove(id);
    } else {
      _savedIds.add(id);
    }
    notifyListeners();
  }

  void save(String id) {
    if (!_savedIds.contains(id)) {
      _savedIds.add(id);
      notifyListeners();
    }
  }

  void unsave(String id) {
    if (_savedIds.contains(id)) {
      _savedIds.remove(id);
      notifyListeners();
    }
  }
}
