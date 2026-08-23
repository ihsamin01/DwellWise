import 'package:supabase_flutter/supabase_flutter.dart';

/// One past conversation, as shown in the history panel.
class AssistantConversation {
  const AssistantConversation({
    required this.id,
    required this.title,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final DateTime updatedAt;
}

/// One stored turn.
class StoredMessage {
  const StoredMessage({
    required this.role,
    required this.content,
    required this.propertyIds,
  });

  final String role;
  final String content;
  final List<String> propertyIds;

  bool get isUser => role == 'user';
}

/// Saves and reloads assistant conversations.
class AssistantHistoryService {
  SupabaseClient get _client => Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  /// Recent conversations, most recently used first.
  Future<List<AssistantConversation>> recent({int limit = 10}) async {
    final me = _userId;
    if (me == null) return [];

    final rows = await _client
        .from('ai_conversations')
        .select('id, title, updated_at')
        .eq('user_id', me)
        .order('updated_at', ascending: false)
        .limit(limit);

    return [
      for (final row in rows)
        AssistantConversation(
          id: row['id'] as String,
          title: (row['title'] as String?)?.trim().isNotEmpty == true
              ? row['title'] as String
              : 'Untitled',
          updatedAt: DateTime.tryParse(row['updated_at'] as String? ?? '') ??
              DateTime.now(),
        ),
    ];
  }

  /// Starts a conversation, titled from the message that opened it.
  Future<String?> create(String firstMessage) async {
    final me = _userId;
    if (me == null) return null;

    final title = firstMessage.trim();
    final row = await _client
        .from('ai_conversations')
        .insert({
          'user_id': me,
          'title': title.length > 60 ? '${title.substring(0, 60)}…' : title,
        })
        .select('id')
        .single();

    return row['id'] as String;
  }

  Future<void> addMessage({
    required String conversationId,
    required String role,
    required String content,
    List<String> propertyIds = const [],
  }) async {
    await _client.from('ai_messages').insert({
      'conversation_id': conversationId,
      'role': role,
      'content': content,
      'property_ids': propertyIds,
    });
  }

  Future<List<StoredMessage>> messages(String conversationId) async {
    final rows = await _client
        .from('ai_messages')
        .select('role, content, property_ids')
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true);

    return [
      for (final row in rows)
        StoredMessage(
          role: row['role'] as String? ?? 'assistant',
          content: row['content'] as String? ?? '',
          propertyIds: [
            for (final id in (row['property_ids'] as List? ?? const []))
              id.toString(),
          ],
        ),
    ];
  }

  Future<void> delete(String conversationId) =>
      _client.from('ai_conversations').delete().eq('id', conversationId);
}
