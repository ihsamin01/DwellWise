import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/chat_message_model.dart';
import '../models/chat_model.dart';

/// Supabase data access for conversations and messages.
class ChatService {
  SupabaseClient get _client => Supabase.instance.client;

  StreamSubscription<AuthState>? _authChanges;

  String? get currentUserId => _client.auth.currentUser?.id;

  /// Every conversation the user takes part in, newest activity first.
  Future<List<ChatModel>> fetchChats() async {
    final me = currentUserId;
    if (me == null) return [];

    final rows = await _client
        .from('chats')
        .select('id, participant_a, participant_b, last_message, '
            'last_message_time, last_message_sender_id, is_priority, '
            'is_muted, created_at')
        .or('participant_a.eq.$me,participant_b.eq.$me')
        .order('last_message_time', ascending: false, nullsFirst: false);

    if (rows.isEmpty) return [];

    // Resolve the other participant of every chat in one round trip rather.
    final otherIds = <String>{
      for (final row in rows)
        row['participant_a'] == me
            ? row['participant_b'] as String
            : row['participant_a'] as String,
    };

    final profiles = await _client
        .from('profiles')
        .select('id, name, avatar_url, phone_number')
        .inFilter('id', otherIds.toList());

    final byId = <String, Map<String, dynamic>>{
      for (final p in profiles) p['id'] as String: p,
    };

    final unread = await _unreadCounts(rows.map((r) => r['id'] as String));

    return [
      for (final row in rows)
        _toChatModel(row, me, byId, unread[row['id']] ?? 0),
    ];
  }

  /// Unread counts per chat, counting only what the other person sent.
  Future<Map<String, int>> _unreadCounts(Iterable<String> chatIds) async {
    final me = currentUserId;
    if (me == null || chatIds.isEmpty) return {};

    final rows = await _client
        .from('messages')
        .select('chat_id')
        .inFilter('chat_id', chatIds.toList())
        .eq('is_read', false)
        .neq('sender_id', me);

    final counts = <String, int>{};
    for (final row in rows) {
      final id = row['chat_id'] as String;
      counts[id] = (counts[id] ?? 0) + 1;
    }
    return counts;
  }

  ChatModel _toChatModel(
    Map<String, dynamic> row,
    String me,
    Map<String, Map<String, dynamic>> profilesById,
    int unreadCount,
  ) {
    final otherId = row['participant_a'] == me
        ? row['participant_b'] as String
        : row['participant_a'] as String;
    final name = (profilesById[otherId]?['name'] as String?)?.trim();

    return ChatModel(
      id: row['id'] as String,
      userName: (name == null || name.isEmpty) ? 'DwellWise user' : name,
      userImage: profilesById[otherId]?['avatar_url'] as String?,
      lastMessage: row['last_message'] as String? ?? '',
      lastMessageTime:
          DateTime.tryParse(row['last_message_time'] as String? ?? '') ??
              DateTime.tryParse(row['created_at'] as String? ?? '') ??
              DateTime.now(),
      unreadCount: unreadCount,
      isMuted: row['is_muted'] as bool? ?? false,
      isPriority: row['is_priority'] as bool? ?? false,
      lastMessageSenderId: row['last_message_sender_id'] as String?,
      otherUserId: otherId,
      otherUserPhone: profilesById[otherId]?['phone_number'] as String?,
    );
  }

  /// The existing conversation with [otherUserId], or a newly created one.
  Future<String> findOrCreateChat({
    required String otherUserId,
    String? propertyId,
  }) async {
    final me = currentUserId;
    if (me == null) {
      throw StateError('Cannot open a conversation while signed out.');
    }

    final existing = await _client
        .from('chats')
        .select('id')
        .or('and(participant_a.eq.$me,participant_b.eq.$otherUserId),'
            'and(participant_a.eq.$otherUserId,participant_b.eq.$me)')
        .limit(1);

    if (existing.isNotEmpty) return existing.first['id'] as String;

    final inserted = await _client
        .from('chats')
        .insert({
          'participant_a': me,
          'participant_b': otherUserId,
          if (propertyId != null) 'property_id': propertyId,
          'last_message_time': DateTime.now().toUtc().toIso8601String(),
        })
        .select('id')
        .single();

    return inserted['id'] as String;
  }

  /// Uploads a chat attachment and returns its public URL.
  Future<String?> uploadAttachment(String localPath) async {
    final me = currentUserId;
    if (me == null) return null;

    final file = File(localPath);
    if (!file.existsSync()) return null;

    final ext = localPath.contains('.') ? localPath.split('.').last : 'bin';
    final objectPath = '$me/${DateTime.now().millisecondsSinceEpoch}.$ext';

    try {
      await _client.storage.from('chat-attachments').upload(objectPath, file);
      return _client.storage.from('chat-attachments').getPublicUrl(objectPath);
    } catch (_) {
      return null;
    }
  }

  Future<List<ChatMessageModel>> fetchMessages(String chatId) async {
    final rows = await _client
        .from('messages')
        .select()
        .eq('chat_id', chatId)
        .order('created_at', ascending: true);

    return [for (final row in rows) _toMessage(row)];
  }

  Future<ChatMessageModel> sendMessage({
    required String chatId,
    required String text,
    String? attachmentUrl,
    MessageType type = MessageType.text,
    int? durationMs,
    double? latitude,
    double? longitude,
  }) async {
    final me = currentUserId;
    if (me == null) {
      throw StateError('Cannot send a message while signed out.');
    }

    final row = await _client
        .from('messages')
        .insert({
          'chat_id': chatId,
          'sender_id': me,
          'message': text,
          'type': type.name,
          if (attachmentUrl != null) 'attachment_url': attachmentUrl,
          if (durationMs != null) 'duration_ms': durationMs,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
        })
        .select()
        .single();

    return _toMessage(row);
  }

  /// Marks everything the other person sent in this chat as read.
  Future<void> markRead(String chatId) async {
    final me = currentUserId;
    if (me == null) return;
    await _client
        .from('messages')
        .update({'is_read': true})
        .eq('chat_id', chatId)
        .eq('is_read', false)
        .neq('sender_id', me);
  }

  Future<void> deleteChat(String chatId) =>
      _client.from('chats').delete().eq('id', chatId);

  Future<void> setMuted(String chatId, bool muted) =>
      _client.from('chats').update({'is_muted': muted}).eq('id', chatId);

  Future<void> setPriority(String chatId, bool priority) =>
      _client.from('chats').update({'is_priority': priority}).eq('id', chatId);

  /// Calls [onMessage] for every message inserted into any chat the user can,
  /// and [onUpdated] when one changes — which is how a read receipt arrives,
  /// since marking a chat read is an update to rows the sender is watching.
  RealtimeChannel subscribeToAllMessages(
    void Function(ChatMessageModel message) onMessage, {
    void Function(ChatMessageModel message)? onUpdated,
  }) {
    return _client
        .channel('messages:inbox')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) => onMessage(_toMessage(payload.newRecord)),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'messages',
          callback: (payload) => onUpdated?.call(_toMessage(payload.newRecord)),
        )
        .subscribe();
  }

  /// Announces this user as present and reports who else is, as it changes.
  ///
  /// Presence lives on the realtime channel rather than in a column, so it
  /// clears itself when the app dies or the network drops — nobody is left
  /// showing as online because their last write never happened.
  RealtimeChannel subscribeToPresence(
    void Function(Set<String> onlineUserIds) onChange,
  ) {
    final channel = _client.channel('presence:online');
    var joined = false;

    void publish() {
      onChange({
        for (final state in channel.presenceState())
          for (final presence in state.presences)
            if (presence.payload['user_id'] is String)
              presence.payload['user_id'] as String,
      });
    }

    void announce() {
      final me = currentUserId;
      if (joined && me != null) channel.track({'user_id': me});
    }

    channel
        .onPresenceSync((_) => publish())
        .onPresenceJoin((_) => publish())
        .onPresenceLeave((_) => publish())
        .subscribe((status, _) {
      joined = status == RealtimeSubscribeStatus.subscribed;
      announce();
    });

    // The stored session is restored a moment after start-up, so the first
    // announcement usually happens before there is anyone to announce.
    // Signing in runs it again; signing out takes the user back off the list.
    _authChanges = _client.auth.onAuthStateChange.listen((state) {
      if (state.session == null) {
        if (joined) channel.untrack();
      } else {
        announce();
      }
    });

    return channel;
  }

  /// Stops announcing this user and drops the presence channel.
  Future<void> stopPresence(RealtimeChannel channel) async {
    await _authChanges?.cancel();
    _authChanges = null;
    await _client.removeChannel(channel);
  }

  Future<void> unsubscribe(RealtimeChannel channel) =>
      _client.removeChannel(channel);

  ChatMessageModel _toMessage(Map<String, dynamic> row) {
    return ChatMessageModel(
      id: row['id'] as String,
      chatId: row['chat_id'] as String,
      senderId: row['sender_id'] as String,
      message: row['message'] as String? ?? '',
      attachmentUrl: row['attachment_url'] as String?,
      type: _typeFrom(row['type'] as String?),
      durationMs: (row['duration_ms'] as num?)?.toInt(),
      latitude: (row['latitude'] as num?)?.toDouble(),
      longitude: (row['longitude'] as num?)?.toDouble(),
      isRead: row['is_read'] as bool? ?? false,
      createdAt: DateTime.tryParse(row['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  static MessageType _typeFrom(String? value) {
    return MessageType.values.firstWhere(
      (t) => t.name == value,
      orElse: () => MessageType.text,
    );
  }
}
