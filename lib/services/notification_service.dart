import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/notification_model.dart';

/// Supabase data access for the notification inbox.
class NotificationService {
  SupabaseClient get _client => Supabase.instance.client;

  String? get currentUserId => _client.auth.currentUser?.id;

  Future<List<NotificationModel>> fetch({int limit = 50}) async {
    final me = currentUserId;
    if (me == null) return [];

    final rows = await _client
        .from('notifications')
        .select()
        .eq('user_id', me)
        .order('created_at', ascending: false)
        .limit(limit);

    return [for (final row in rows) _toModel(row)];
  }

  Future<NotificationModel?> add({
    required NotificationKind kind,
    required String title,
    required String message,
  }) async {
    final me = currentUserId;
    if (me == null) return null;

    final row = await _client
        .from('notifications')
        .insert({
          'user_id': me,
          'kind': kind.name,
          'title': title,
          'message': message,
        })
        .select()
        .single();

    return _toModel(row);
  }

  Future<void> markRead(String id) => _client
      .from('notifications')
      .update({'is_read': true})
      .eq('id', id);

  Future<void> markAllRead() async {
    final me = currentUserId;
    if (me == null) return;
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', me)
        .eq('is_read', false);
  }

  /// Calls [onInsert] whenever a notification is raised for this user.
  RealtimeChannel subscribe(void Function(NotificationModel) onInsert) {
    return _client
        .channel('notifications:inbox')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          callback: (payload) => onInsert(_toModel(payload.newRecord)),
        )
        .subscribe();
  }

  Future<void> unsubscribe(RealtimeChannel channel) =>
      _client.removeChannel(channel);

  NotificationModel _toModel(Map<String, dynamic> row) {
    final kind = NotificationKind.fromName(row['kind'] as String?);
    return NotificationModel(
      id: row['id'] as String,
      icon: kind.icon,
      title: row['title'] as String? ?? '',
      message: row['message'] as String? ?? '',
      timestamp: DateTime.tryParse(row['created_at'] as String? ?? '')
              ?.toLocal() ??
          DateTime.now(),
      isRead: row['is_read'] as bool? ?? false,
    );
  }
}
