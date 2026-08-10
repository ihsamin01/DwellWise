import 'dart:io';

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

  /// Searches approved listings by location. Matching is done on the address,
  /// which holds "<thana/area>, <district>", so an area, a thana or a whole
  /// district all resolve. [district] narrows names that repeat across the
  /// country (Kotwali, New Market, Sadar …).
  Future<List<PropertyModel>> searchProperties({
    String? area,
    String? thana,
    String? district,
    String? type,
    int limit = 60,
  }) async {
    final client = _client;
    if (client == null) return [];

    Future<List<PropertyModel>> run(String locality) async {
      var builder = client
          .from('properties')
          .select()
          .eq('status', 'approved')
          .ilike('address', '%$locality%');

      // Narrow names that repeat across the country (Kotwali, Sadar, Mirpur…).
      final d = district?.trim() ?? '';
      if (d.isNotEmpty && d != locality) {
        builder = builder.ilike('address', '%$d%');
      }
      if (type != null && type.trim().isNotEmpty) {
        builder = builder.eq('property_type', type.trim());
      }

      final response =
          await builder.order('created_at', ascending: false).limit(limit);
      return (response as List)
          .map((p) => PropertyModel.fromJson(p as Map<String, dynamic>))
          .toList();
    }

    // Most specific first, widening until something matches: a neighbourhood
    // like "Kalai Sadar" has no listings of its own, so fall back to its thana
    // ("Kalai") and then to the district.
    for (final locality in [area, thana, district]) {
      final term = locality?.trim() ?? '';
      if (term.isEmpty) continue;
      final hits = await run(term);
      if (hits.isNotEmpty) return hits;
    }
    return [];
  }

  /// Fetches the listings posted by the signed-in user (newest first), so
  /// "My properties" survives an app restart. Includes listings of any status
  /// because Row Level Security lets an owner see their own rows.
  Future<List<PropertyModel>> getMyProperties() async {
    final client = _client;
    final uid = client?.auth.currentUser?.id;
    if (client == null || uid == null) return [];
    final response = await client
        .from('properties')
        .select()
        .eq('owner_id', uid)
        .order('created_at', ascending: false);
    return (response as List)
        .map((p) => PropertyModel.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  /// Deletes one of the signed-in user's listings.
  Future<void> deleteProperty(String propertyId) async {
    final client = _client;
    if (client == null) return;
    try {
      await client.from('properties').delete().eq('id', propertyId);
    } catch (_) {
      // Non-fatal: it still disappears from this session's list.
    }
  }

  /// Uploads listing photos to the public `property-images` bucket and returns
  /// their public URLs, so the same images render on every device. Files that
  /// fail to upload are skipped rather than failing the whole post.
  Future<List<String>> uploadPropertyImages(List<File> files) async {
    final client = _client;
    if (client == null || files.isEmpty) return [];

    final uid = client.auth.currentUser?.id ?? 'anonymous';
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final urls = <String>[];

    for (var i = 0; i < files.length; i++) {
      final file = files[i];
      final ext = file.path.contains('.') ? file.path.split('.').last : 'jpg';
      final objectPath = '$uid/${stamp}_$i.$ext';
      try {
        await client.storage.from('property-images').upload(objectPath, file);
        urls.add(
            client.storage.from('property-images').getPublicUrl(objectPath));
      } catch (_) {
        // Skip this image; the listing is still posted.
      }
    }
    return urls;
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

  /// Uploads NID/passport photos to the private `verification-docs` bucket and
  /// returns their storage paths. Failures are skipped so a flaky upload does
  /// not block the verification itself.
  Future<List<String>> uploadVerificationDocs(List<File> files) async {
    final client = _client;
    final uid = client?.auth.currentUser?.id;
    if (client == null || uid == null || files.isEmpty) return [];

    final stamp = DateTime.now().millisecondsSinceEpoch;
    final paths = <String>[];
    for (var i = 0; i < files.length; i++) {
      final file = files[i];
      final ext = file.path.contains('.') ? file.path.split('.').last : 'jpg';
      final objectPath = '$uid/${stamp}_$i.$ext';
      try {
        await client.storage.from('verification-docs').upload(objectPath, file);
        paths.add(objectPath);
      } catch (_) {
        // Skip this document.
      }
    }
    return paths;
  }

  /// Records the verification request and marks the profile verified. The app
  /// has no admin review step, so payment completes the process immediately.
  Future<bool> submitVerification({
    required String fullName,
    required String governmentId,
    List<String> documentPaths = const [],
  }) async {
    final client = _client;
    final uid = client?.auth.currentUser?.id;
    if (client == null || uid == null) return false;

    try {
      await client.from('verification_requests').insert({
        'user_id': uid,
        'full_name': fullName,
        'document_url': documentPaths.isEmpty ? null : documentPaths.first,
        'fee_paid': true,
        'status': 'verified',
      });
    } catch (_) {
      // Keep going: the profile flag below is what the UI reads.
    }

    try {
      await client.from('profiles').update({
        'verification_status': 'verified',
        'government_id': governmentId,
      }).eq('id', uid);
      return true;
    } catch (_) {
      // The government_id column may not exist yet — retry without it.
      try {
        await client
            .from('profiles')
            .update({'verification_status': 'verified'}).eq('id', uid);
        return true;
      } catch (_) {
        return false;
      }
    }
  }

  /// Fetches the ids of properties the signed-in user has saved/favorited, so
  /// the saved list survives logging out and back in (or reinstalling).
  Future<Set<String>> getSavedPropertyIds() async {
    final client = _client;
    final uid = client?.auth.currentUser?.id;
    if (client == null || uid == null) return {};
    try {
      final response = await client
          .from('saved_properties')
          .select('property_id')
          .eq('user_id', uid);
      return (response as List)
          .map((row) => row['property_id'] as String)
          .toSet();
    } catch (_) {
      return {};
    }
  }

  /// Persists a favorite. Non-fatal: the local save already reflects the
  /// change even if this write is rejected (e.g. a demo property that has no
  /// matching row in the `properties` table).
  Future<void> saveProperty(String propertyId) async {
    final client = _client;
    final uid = client?.auth.currentUser?.id;
    if (client == null || uid == null) return;
    try {
      await client
          .from('saved_properties')
          .upsert({'user_id': uid, 'property_id': propertyId});
    } catch (_) {
      // Keep the local save working even if the insert is rejected.
    }
  }

  /// Removes a favorite from the database.
  Future<void> unsaveProperty(String propertyId) async {
    final client = _client;
    final uid = client?.auth.currentUser?.id;
    if (client == null || uid == null) return;
    try {
      await client
          .from('saved_properties')
          .delete()
          .eq('user_id', uid)
          .eq('property_id', propertyId);
    } catch (_) {
      // Keep the local unsave working even if the delete is rejected.
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
