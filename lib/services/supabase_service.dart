import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/property_model.dart';
import '../models/user_model.dart';

/// Thrown when an action needs a signed-in account and there is none.
class NotSignedIn implements Exception {
  const NotSignedIn();

  @override
  String toString() => 'Not signed in';
}

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

  /// Fetches listings in [area].
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

  /// Searches approved listings by location.
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

    // Most specific first, widening until something matches.
    for (final locality in [area, thana, district]) {
      final term = locality?.trim() ?? '';
      if (term.isEmpty) continue;
      final hits = await run(term);
      if (hits.isNotEmpty) return hits;
    }
    return [];
  }

  /// Fetches the listings posted by the signed-in user (newest first).
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
      // Non-fatal.
    }
  }

  /// Uploads listing photos to the public `property-images` bucket and returns.
  /// Why the last photo upload failed, for the screen to show.
  String? lastImageUploadError;

  Future<List<String>> uploadPropertyImages(List<File> files) async {
    final client = _client;
    lastImageUploadError = null;
    if (client == null || files.isEmpty) return [];

    final uid = client.auth.currentUser?.id;
    if (uid == null) {
      lastImageUploadError = 'you are not signed in';
      return [];
    }
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
      } catch (e) {
        // Worth saying out loud: a silent skip here used to post the listing
        // with no photos and no hint as to why.
        lastImageUploadError = '$e';
        debugPrint('Property image upload failed for $objectPath: $e');
      }
    }
    return urls;
  }

  /// Uploads a profile photo to the public `avatars` bucket and returns its
  /// public URL, overwriting any previous photo for this user.
  Future<String?> uploadAvatar(File file) async {
    final client = _client;
    final uid = client?.auth.currentUser?.id;
    if (client == null || uid == null) return null;

    final ext = file.path.contains('.') ? file.path.split('.').last : 'jpg';
    final objectPath = '$uid/avatar.$ext';
    try {
      await client.storage.from('avatars').upload(
            objectPath,
            file,
            fileOptions: const FileOptions(upsert: true),
          );
      final url = client.storage.from('avatars').getPublicUrl(objectPath);
      // Bust the CDN/cache so the new photo shows immediately, not the old
      // one still cached under the same object path.
      return '$url?t=${DateTime.now().millisecondsSinceEpoch}';
    } catch (_) {
      return null;
    }
  }

  /// Inserts a new property listing.
  Future<void> createProperty(PropertyModel property) async {
    final client = _client;
    if (client == null) return;
    final data = property.toJson()..remove('id');
    final uid = client.auth.currentUser?.id;
    if (uid == null) throw const NotSignedIn();
    data['owner_id'] = uid;
    await client.from('properties').insert(data);
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

  /// Uploads NID/passport photos to the private `verification-docs` bucket and.
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

  /// Records the verification request and marks the profile verified.
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
      // Keep going.
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

  /// Fetches the ids of properties the signed-in user has saved/favorited.
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

  /// Persists a favorite.
  Future<Map<String, dynamic>?> getOwnerProfile(String ownerId) async {
    final client = _client;
    if (client == null || ownerId.isEmpty) return null;

    try {
      final rows = await client
          .from('profiles')
          .select('id, name, phone_number, verification_status')
          .eq('id', ownerId)
          .limit(1);
      return rows.isEmpty ? null : rows.first;
    } catch (_) {
      // Not a uuid, so not an account.
      return null;
    }
  }

  /// Listings for [ids], in one query.
  Future<List<PropertyModel>> getPropertiesByIds(List<String> ids) async {
    final client = _client;
    if (client == null || ids.isEmpty) return [];

    final rows =
        await client.from('properties').select().inFilter('id', ids);
    return [for (final row in rows) PropertyModel.fromJson(row)];
  }

  /// One listing by id, or null when it does not exist.
  Future<PropertyModel?> getPropertyById(String id) async {
    final client = _client;
    if (client == null || id.isEmpty) return null;

    final rows =
        await client.from('properties').select().eq('id', id).limit(1);
    if (rows.isEmpty) return null;
    return PropertyModel.fromJson(rows.first);
  }

  /// Approved listings whose area name contains [area].
  Future<List<PropertyModel>> getApprovedPropertiesInArea(
    String area, {
    int limit = 200,
  }) async {
    final client = _client;
    if (client == null || area.trim().isEmpty) return [];

    final rows = await client
        .from('properties')
        .select()
        .eq('status', 'approved')
        .ilike('area', '%${area.trim()}%')
        .limit(limit);

    return [
      for (final row in rows) PropertyModel.fromJson(row),
    ];
  }

  /// Approved listings inside a bounding box around a point.
  Future<List<PropertyModel>> getApprovedPropertiesNear({
    required double latitude,
    required double longitude,
    required double radiusKm,
    int limit = 300,
  }) async {
    final client = _client;
    if (client == null) return [];

    final latSpan = radiusKm / 111.0;
    final lngSpan = radiusKm / (111.0 * math.cos(latitude * math.pi / 180).abs());

    final rows = await client
        .from('properties')
        .select()
        .eq('status', 'approved')
        .gte('latitude', latitude - latSpan)
        .lte('latitude', latitude + latSpan)
        .gte('longitude', longitude - lngSpan)
        .lte('longitude', longitude + lngSpan)
        .limit(limit);

    return [
      for (final row in rows) PropertyModel.fromJson(row),
    ];
  }

  /// The signed-in user's saved properties, newest save first.
  Future<List<PropertyModel>> getSavedProperties({int limit = 100}) async {
    final client = _client;
    final uid = client?.auth.currentUser?.id;
    if (client == null || uid == null) return [];

    final rows = await client
        .from('saved_properties')
        .select('property_id, created_at, properties(*)')
        .eq('user_id', uid)
        .order('created_at', ascending: false)
        .limit(limit);

    final saved = <PropertyModel>[];
    for (final row in rows) {
      final property = row['properties'];
      if (property is Map<String, dynamic>) {
        saved.add(PropertyModel.fromJson(property));
      }
    }
    return saved;
  }

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

  /// Fetches the signed-in user's most recently viewed property ids (newest.
  Future<List<String>> getRecentlyViewedIds({int limit = 5}) async {
    final client = _client;
    final uid = client?.auth.currentUser?.id;
    if (client == null || uid == null) return [];
    try {
      final response = await client
          .from('recently_viewed')
          .select('property_id')
          .eq('user_id', uid)
          .order('viewed_at', ascending: false)
          .limit(limit);
      return (response as List)
          .map((row) => row['property_id'] as String)
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Records (or bumps the recency of) a property view.
  Future<void> recordPropertyView(String propertyId) async {
    final client = _client;
    final uid = client?.auth.currentUser?.id;
    if (client == null || uid == null) return;
    try {
      await client.from('recently_viewed').upsert({
        'user_id': uid,
        'property_id': propertyId,
        'viewed_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (_) {
      // Keep the local history working even if the write is rejected.
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
