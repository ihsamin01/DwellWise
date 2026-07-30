import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/supabase_service.dart';

/// Provider handling user profiles and account metadata settings.
class UserProvider with ChangeNotifier {
  final SupabaseService _dbService = SupabaseService();

  UserModel? _userModel;
  bool _isLoading = false;

  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;

  /// Loads the profile of the currently signed-in Supabase user.
  Future<void> loadCurrentUserProfile() async {
    final authUser = Supabase.instance.client.auth.currentUser;
    if (authUser == null) {
      _userModel = null;
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      final profile = await _dbService.getUserProfile(authUser.id);
      if (profile != null) {
        _userModel = profile;
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clears the cached profile (e.g. on logout).
  void clear() {
    _userModel = null;
    notifyListeners();
  }

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
  /// This is a frontend-only demo: it simulates a brief processing delay and
  /// then marks the account [VerificationStatus.verified] directly — there is
  /// no backend or real admin review.
  Future<bool> submitVerification({required String governmentId}) async {
    if (_userModel == null) return false;
    _isLoading = true;
    notifyListeners();
    // Simulate the mock payment + verification round-trip.
    await Future.delayed(const Duration(milliseconds: 600));
    _userModel = _userModel!.copyWith(
      verificationStatus: VerificationStatus.verified,
      governmentId: governmentId,
    );
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
