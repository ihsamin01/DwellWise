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
      _userModel = _userModel!.copyWith(role: newRole);
      notifyListeners();
    }
  }

  /// Current account verification lifecycle state.
  VerificationStatus get verificationStatus =>
      _userModel?.verificationStatus ?? VerificationStatus.unverified;

  /// Submits the account-verification request (form + mock ৳500 fee paid).
  /// Moves the account into [VerificationStatus.pending] awaiting admin review.
  Future<bool> submitVerification() async {
    if (_userModel == null) return false;
    _isLoading = true;
    notifyListeners();
    // Simulate the request reaching the admin queue.
    await Future.delayed(const Duration(milliseconds: 600));
    _userModel = _userModel!.copyWith(verificationStatus: VerificationStatus.pending);
    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Mock admin approval that grants the green verified badge. In a real
  /// build this would be triggered from the admin dashboard.
  void approveVerification() {
    if (_userModel == null) return;
    _userModel = _userModel!.copyWith(verificationStatus: VerificationStatus.verified);
    notifyListeners();
  }
}
