import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/property_model.dart';
import '../models/user_model.dart';

/// Service handler interfacing with Supabase DB client operations.
class SupabaseService {
  SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Fetches the newest approved listings for the home feed.
  Future<List<PropertyModel>> getProperties({int limit = 120}) async {
    final client = _client;
    if (client == null) return [];
    final response = await client
        .from('properties')
        .select()
        .eq('status', 'approved')
        .order('created_at', ascending: false)
        .limit(limit);
    return (response as List)
        .map((p) => PropertyModel.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  /// Fetches listings in [area] — used for the location-aware AI Recommended
  /// feed.
  ///
  /// [city] disambiguates place names that exist in more than one division
  /// (e.g. Chawkbazar is in both Dhaka and Chattogram): when given, only
  /// listings whose address also mentions that city are returned.
  Future<List<PropertyModel>> getPropertiesByArea(
    String area, {
    String? city,
    int limit = 20,
  }) async {
    final client = _client;
    if (client == null || area.trim().isEmpty) return [];
    final term = area.trim();

    var builder = client
        .from('properties')
        .select()
        .eq('status', 'approved')
        .ilike('area', '%$term%');

    if (city != null && city.trim().isNotEmpty) {
      builder = builder.ilike('address', '%${city.trim()}%');
    }

    final response =
        await builder.order('created_at', ascending: false).limit(limit);
    return (response as List)
        .map((p) => PropertyModel.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  /// Inserts a new property listing. Row Level Security only accepts rows owned
  /// by the signed-in user, so the caller's owner id is replaced with their auth
  /// id. Failures are non-fatal: the listing still appears locally for the
  /// session, it just isn't persisted.
  Future<void> createProperty(PropertyModel property) async {
    final client = _client;
    if (client == null) return;
    final data = property.toJson()..remove('id');
    final uid = client.auth.currentUser?.id;
    if (uid != null) data['owner_id'] = uid;
    try {
      await client.from('properties').insert(data);
    } catch (e) {
      // Keep the local add working even if the insert is rejected.
    }
  }

  /// Fetches the profile row for [userId] from the `profiles` table.
  Future<UserModel?> getUserProfile(String userId) async {
    final client = _client;
    if (client == null) return null;
    try {
      final response = await client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return response != null ? UserModel.fromJson(response) : null;
    } catch (e) {
      rethrow;
    }
  }

  /// Updates the editable profile fields for [user] in the DB.
  Future<void> updateUserProfile(UserModel user) async {
    final client = _client;
    if (client == null) return;
    try {
      await client.from('profiles').update({
        'name': user.name,
        'phone_number': user.phoneNumber,
        'address': user.address,
        'avatar_url': user.avatarUrl,
        'gender': user.gender,
      }).eq('id', user.id);
    } catch (e) {
      rethrow;
    }
  }
}
