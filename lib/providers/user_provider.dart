import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/supabase_service.dart';

/// Provider handling user profiles and account metadata settings.
class UserProvider with ChangeNotifier {
  final SupabaseService _dbService = SupabaseService();

  UserModel? _userModel = UserModel(
    id: 'tenant1',
    email: 'samin@dwellwise.com',
    name: 'Samin Azhan',
    phoneNumber: '+8801700000000',
    role: UserRole.tenant,
    createdAt: DateTime(2025, 11, 4),
  );
  bool _isLoading = false;

  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;

  /// Loads detailed profile record for authenticated user ID.
  Future<void> fetchUserProfile(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _userModel = await _dbService.getUserProfile(userId);
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates profile metadata in database.
  Future<bool> updateProfile(UserModel updatedUser) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _dbService.updateUserProfile(updatedUser);
      _userModel = updatedUser;
      return true;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggles between Seeker and Owner visual perspectives.
  void switchPerspective(UserRole newRole) {
    if (_userModel != null) {
      _userModel = UserModel(
        id: _userModel!.id,
        email: _userModel!.email,
        name: _userModel!.name,
        phoneNumber: _userModel!.phoneNumber,
        role: newRole,
        avatarUrl: _userModel!.avatarUrl,
        createdAt: _userModel!.createdAt,
      );
      notifyListeners();
    }
  }
}
