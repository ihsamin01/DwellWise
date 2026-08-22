import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/chat_message_model.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';

/// Provider handling instant messaging conversations and attachments.
///
/// Backed by the `chats` / `messages` tables. Sends are optimistic: the
/// message is shown immediately and reconciled with the row the server
/// returns, so the thread never feels like it is waiting on the network. New
/// messages arrive over a Realtime subscription; row-level security means the
/// subscription only ever delivers messages from the user's own chats, so no
/// filtering by chat is needed on the client.
class ChatProvider with ChangeNotifier {
  ChatProvider() {
    _listenForMessages();
  }

  final ChatService _service = ChatService();

  final List<ChatModel> _chats = [];
  final Map<String, List<ChatMessageModel>> _messagesByChatId = {};
  final List<ChatMessageModel> _activeMessages = [];

  RealtimeChannel? _messagesChannel;

  /// Why the last send failed, for the screen to show. A send that quietly
  /// disappears is impossible to diagnose from the outside.
  String? lastSendError;

  bool _isTyping = false;
  bool _isLoading = false;
  String _searchQuery = '';
  String? _activeChatId;
  bool _hasLoadedChats = false;

  /// The signed-in user's id — what message bubbles compare against to decide
  /// which side of the thread they belong on.
  String? get currentUserId => _service.currentUserId;

  List<ChatModel> get chats => _buildConversationList();
  List<ChatModel> get conversations => chats;

  List<ChatMessageModel> get activeMessages => _activeMessages;
  bool get isTyping => _isTyping;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get activeChatId => _activeChatId;

  int get unreadConversationCount =>
      _chats.where((chat) => chat.unreadCount > 0 && !chat.isMuted).length;

  @override
  void dispose() {
    final channel = _messagesChannel;
    if (channel != null) _service.unsubscribe(channel);
    super.dispose();
  }

  // ── loading ────────────────────────────────────────────────────────────

  void loadChats({bool forceReload = false}) {
    if (_hasLoadedChats && !forceReload) return;
    _hasLoadedChats = true;
    refreshChats();
  }

  Future<void> refreshChats() async {
    if (_service.currentUserId == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final fetched = await _service.fetchChats();
      _chats
        ..clear()
        ..addAll(fetched);
    } catch (_) {
      // Offline or refused: keep whatever is already on screen rather than
      // blanking the inbox.
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Loads a thread from the server, then marks it read.
  Future<void> loadChatHistory(String chatId) async {
    try {
      final messages = await _service.fetchMessages(chatId);
      _messagesByChatId[chatId] = messages;
      _syncActiveMessages(chatId);
      notifyListeners();
      await markConversationRead(chatId);
    } catch (_) {
      // Leave any cached messages in place.
    }
  }

  // ── conversations ──────────────────────────────────────────────────────

  void searchConversations(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  List<ChatMessageModel> messagesForChat(String chatId) =>
      List.unmodifiable(_messagesByChatId[chatId] ?? const []);

  ChatModel? chatById(String chatId) {
    for (final chat in _chats) {
      if (chat.id == chatId) return chat;
    }
    return null;
  }

  void openConversation(String chatId) {
    _activeChatId = chatId;
    _syncActiveMessages(chatId);
    notifyListeners();
    loadChatHistory(chatId);
  }

  /// Opens the thread with a property's owner, creating it on first contact.
  ///
  /// Asynchronous because the chat row has to exist before it can be opened —
  /// the id is the database's, so both participants resolve to the same
  /// conversation.
  Future<String?> startConversationWithOwner({
    required String ownerId,
    required String ownerName,
    String? ownerImage,
    String? propertyId,
  }) async {
    if (_service.currentUserId == null) return null;
    if (_service.currentUserId == ownerId) return null;

    // Seeded demo listings carry ids like 'o10' rather than a user id. A chat
    // needs a real profile on the other side, so there is nobody to open a
    // conversation with — caught here so the screen can say why.
    if (!_looksLikeUserId(ownerId)) return null;

    try {
      final chatId = await _service.findOrCreateChat(
        otherUserId: ownerId,
        propertyId: propertyId,
      );

      if (chatById(chatId) == null) {
        _chats.insert(
          0,
          ChatModel(
            id: chatId,
            userName: ownerName,
            userImage: ownerImage,
            lastMessage: '',
            lastMessageTime: DateTime.now(),
          ),
        );
        notifyListeners();
      }
      return chatId;
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteConversation(String chatId) async {
    _chats.removeWhere((chat) => chat.id == chatId);
    _messagesByChatId.remove(chatId);
    if (_activeChatId == chatId) {
      _activeChatId = null;
      _activeMessages.clear();
    }
    notifyListeners();
    try {
      await _service.deleteChat(chatId);
    } catch (_) {
      await refreshChats();
    }
  }

  Future<void> muteConversation(String chatId, bool muted) async {
    _replaceChat(chatId, (chat) => chat.copyWith(isMuted: muted));
    try {
      await _service.setMuted(chatId, muted);
    } catch (_) {
      _replaceChat(chatId, (chat) => chat.copyWith(isMuted: !muted));
    }
  }

  Future<void> togglePriorityConversation(String chatId) async {
    final current = chatById(chatId);
    if (current == null) return;
    final next = !current.isPriority;
    _replaceChat(chatId, (chat) => chat.copyWith(isPriority: next));
    try {
      await _service.setPriority(chatId, next);
    } catch (_) {
      _replaceChat(chatId, (chat) => chat.copyWith(isPriority: !next));
    }
  }

  Future<void> markConversationRead(String chatId) async {
    _replaceChat(chatId, (chat) => chat.copyWith(unreadCount: 0));
    try {
      await _service.markRead(chatId);
    } catch (_) {
      // The badge reappears on the next refresh if this did not land.
    }
  }

  /// Local-only typing indicator. Not shared with the other participant —
  /// that needs Realtime presence, which is not wired up.
  void setTypingStatus(String chatId, bool isTyping) {
    _isTyping = isTyping;
    _replaceChat(chatId, (chat) => chat.copyWith(isTyping: isTyping));
  }

  // ── sending ────────────────────────────────────────────────────────────

  /// [senderId] is accepted for call-site compatibility but ignored: the
  /// sender is taken from the session, and the database enforces that a
  /// message can only be inserted as its own sender.
  void sendMessage(
    String chatId,
    String senderId,
    String text, {
    String? attachmentUrl,
    MessageType type = MessageType.text,
    int? durationMs,
    double? latitude,
    double? longitude,
  }) {
    _dispatch(
      chatId: chatId,
      text: text,
      attachmentUrl: attachmentUrl,
      type: type,
      durationMs: durationMs,
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Sends an image / pdf / document picked from the device.
  ///
  /// The picker hands back a path on this phone, which is meaningless to the
  /// other participant, so the file is uploaded and the stored URL is what
  /// goes into the message.
  void sendAttachment(
    String chatId,
    String senderId, {
    required String path,
    required String fileName,
    required MessageType type,
  }) {
    _dispatch(
      chatId: chatId,
      text: fileName,
      type: type,
      localPath: path,
    );
  }

  /// Sends a recorded voice note. Uploaded for the same reason as any other
  /// attachment.
  void sendVoiceMessage(
    String chatId,
    String senderId, {
    required String path,
    required int durationMs,
  }) {
    _dispatch(
      chatId: chatId,
      text: '',
      type: MessageType.voice,
      durationMs: durationMs,
      localPath: path,
    );
  }

  /// Shares the user's current location.
  void sendLocation(
    String chatId,
    String senderId, {
    required double latitude,
    required double longitude,
  }) {
    _dispatch(
      chatId: chatId,
      text: 'Shared location',
      type: MessageType.location,
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Sends a sticker — either a bundled gif asset ([assetPath]) or an
  /// emoji-based sticker ([emoji]).
  ///
  /// [assetPath] is deliberately not uploaded: it points into the app bundle,
  /// so it already resolves on the other person's device.
  void sendSticker(
    String chatId,
    String senderId, {
    String? assetPath,
    String? emoji,
  }) {
    _dispatch(
      chatId: chatId,
      text: emoji ?? '',
      attachmentUrl: assetPath,
      type: MessageType.sticker,
    );
  }

  /// Shows the message straight away under a temporary id, then swaps it for
  /// the stored row.
  ///
  /// [localPath] is a file on this device: it is displayed immediately so the
  /// thread does not wait on an upload, then replaced by the uploaded URL
  /// before the message row is written.
  void _dispatch({
    required String chatId,
    required String text,
    String? attachmentUrl,
    String? localPath,
    MessageType type = MessageType.text,
    int? durationMs,
    double? latitude,
    double? longitude,
  }) {
    final me = _service.currentUserId;
    if (me == null) {
      lastSendError = 'You are signed out, so the message was not sent.';
      notifyListeners();
      return;
    }
    lastSendError = null;

    final pending = ChatMessageModel(
      id: 'pending-${DateTime.now().microsecondsSinceEpoch}',
      chatId: chatId,
      senderId: me,
      message: text,
      attachmentUrl: localPath ?? attachmentUrl,
      type: type,
      durationMs: durationMs,
      latitude: latitude,
      longitude: longitude,
      isRead: false,
      createdAt: DateTime.now(),
    );

    _appendMessage(pending);

    Future<void> send() async {
      var url = attachmentUrl;
      if (localPath != null) {
        url = await _service.uploadAttachment(localPath);
        if (url == null) {
          // Nothing was stored, so a message pointing at it would be broken
          // on the other side. Drop the bubble rather than send a dead link.
          lastSendError = 'The attachment could not be uploaded.';
          _removeMessage(chatId, pending.id);
          return;
        }
      }

      final saved = await _service.sendMessage(
        chatId: chatId,
        text: text,
        attachmentUrl: url,
        type: type,
        durationMs: durationMs,
        latitude: latitude,
        longitude: longitude,
      );
      _replaceMessage(pending.id, saved);
    }

    send().catchError((Object error) {
      lastSendError = error.toString();
      _removeMessage(chatId, pending.id);
    });
  }

  static final RegExp _uuid = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  /// Whether [id] is a real account id rather than a seeded placeholder.
  static bool _looksLikeUserId(String id) => _uuid.hasMatch(id);

  // ── realtime ───────────────────────────────────────────────────────────

  void _listenForMessages() {
    _messagesChannel = _service.subscribeToAllMessages(_onRemoteMessage);
  }

  void _onRemoteMessage(ChatMessageModel message) {
    final me = _service.currentUserId;

    // The sender already has this one on screen from the optimistic insert.
    if (message.senderId == me) return;

    _appendMessage(message);
    if (message.chatId == _activeChatId) {
      markConversationRead(message.chatId);
    } else {
      _replaceChat(
        message.chatId,
        (chat) => chat.copyWith(unreadCount: chat.unreadCount + 1),
      );
    }
  }

  // ── internals ──────────────────────────────────────────────────────────

  void _appendMessage(ChatMessageModel message) {
    final messages = _messagesByChatId.putIfAbsent(message.chatId, () => []);
    if (messages.any((m) => m.id == message.id)) return;
    messages.add(message);
    _syncActiveMessages(message.chatId);
    _replaceChat(
      message.chatId,
      (chat) => chat.copyWith(
        lastMessage: _previewFor(message),
        lastMessageTime: message.createdAt,
        lastMessageSenderId: message.senderId,
        lastMessageType: message.type.name,
      ),
    );
    notifyListeners();
  }

  void _replaceMessage(String pendingId, ChatMessageModel saved) {
    final messages = _messagesByChatId[saved.chatId];
    if (messages == null) return;
    final index = messages.indexWhere((m) => m.id == pendingId);
    if (index == -1) return;
    messages[index] = saved;
    _syncActiveMessages(saved.chatId);
    notifyListeners();
  }

  void _removeMessage(String chatId, String messageId) {
    _messagesByChatId[chatId]?.removeWhere((m) => m.id == messageId);
    _syncActiveMessages(chatId);
    notifyListeners();
  }

  /// Applies [update] to one conversation in place. Does nothing when the
  /// chat is not loaded — the next refresh will pick it up.
  void _replaceChat(String chatId, ChatModel Function(ChatModel) update) {
    final index = _chats.indexWhere((chat) => chat.id == chatId);
    if (index == -1) return;
    _chats[index] = update(_chats[index]);
    notifyListeners();
  }

  List<ChatModel> _buildConversationList() {
    final query = _searchQuery.trim().toLowerCase();
    final visible = query.isEmpty
        ? List<ChatModel>.from(_chats)
        : _chats
            .where((chat) =>
                chat.userName.toLowerCase().contains(query) ||
                chat.lastMessage.toLowerCase().contains(query))
            .toList();

    // Priority threads first, then most recent activity.
    visible.sort((a, b) {
      if (a.isPriority != b.isPriority) return a.isPriority ? -1 : 1;
      return b.lastMessageTime.compareTo(a.lastMessageTime);
    });
    return visible;
  }

  String _previewFor(ChatMessageModel message) {
    switch (message.type) {
      case MessageType.image:
        return '📷 Photo';
      case MessageType.pdf:
        return '📄 PDF';
      case MessageType.file:
        return '📎 File';
      case MessageType.voice:
        return '🎤 Voice message';
      case MessageType.location:
        return '📍 Location';
      case MessageType.sticker:
        return message.message.isEmpty ? '💬 Sticker' : message.message;
      case MessageType.text:
        return message.message;
    }
  }

  void _syncActiveMessages(String chatId) {
    if (_activeChatId != chatId) return;
    _activeMessages
      ..clear()
      ..addAll(_messagesByChatId[chatId] ?? const []);
  }
}
