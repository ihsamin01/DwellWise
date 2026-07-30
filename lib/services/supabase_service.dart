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

  /// Fetches all property listings from Database.
  Future<List<PropertyModel>> getProperties() async {
    // Stub: Fetch data from supabase table 'properties'
    try {
      // final response = await _client.from('properties').select();
      // return (response as List).map((p) => PropertyModel.fromJson(p)).toList();
      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Inserts a new property listing.
  Future<void> createProperty(PropertyModel property) async {
    // Stub: Insert property into database
    try {
      // await _client.from('properties').insert(property.toJson());
    } catch (e) {
      rethrow;
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
