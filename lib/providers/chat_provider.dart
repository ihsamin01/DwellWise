import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/chat_message_model.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';
import '../services/push_notifications.dart';

/// Provider handling instant messaging conversations and attachments.
class ChatProvider with ChangeNotifier {
  ChatProvider() {
    _listenForMessages();
  }

  final ChatService _service = ChatService();

  final List<ChatModel> _chats = [];
  final Map<String, List<ChatMessageModel>> _messagesByChatId = {};
  final List<ChatMessageModel> _activeMessages = [];

  RealtimeChannel? _messagesChannel;
  RealtimeChannel? _presenceChannel;
  RealtimeChannel? _profilesChannel;

  /// Why the last send failed, for the screen to show.
  String? lastSendError;

  bool _isTyping = false;
  bool _isLoading = false;
  String _searchQuery = '';
  String? _activeChatId;
  bool _hasLoadedChats = false;

  /// The signed-in user's id.
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

  /// Who is in the app right now, by account id.
  Set<String> _onlineUserIds = const {};

  bool isUserOnline(String? userId) =>
      userId != null && _onlineUserIds.contains(userId);

  @override
  void dispose() {
    final channel = _messagesChannel;
    if (channel != null) _service.unsubscribe(channel);
    final presence = _presenceChannel;
    if (presence != null) _service.stopPresence(presence);
    final profiles = _profilesChannel;
    if (profiles != null) _service.unsubscribe(profiles);
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
      // Offline or refused.
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Loads a thread from the server, then marks it read.
  Future<void> loadChatHistory(String chatId) async {
    try {
      final messages = await _service.fetchMessages(chatId);

      // Anything sent while this was in flight is not in the response yet.
      final fetchedIds = messages.map((m) => m.id).toSet();
      final inFlight = [
        for (final m in _messagesByChatId[chatId] ?? const <ChatMessageModel>[])
          if (!fetchedIds.contains(m.id)) m,
      ];
      _messagesByChatId[chatId] = [...messages, ...inFlight];
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
  Future<String?> startConversationWithOwner({
    required String ownerId,
    required String ownerName,
    String? ownerImage,
    String? propertyId,
  }) async {
    if (_service.currentUserId == null) return null;
    if (_service.currentUserId == ownerId) return null;

    // Seeded demo listings carry ids like 'o10' rather than a user id.
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
            // Without this the thread has no idea who it is with until the
            // chat list is loaded, so the call button has nobody to ring.
            otherUserId: ownerId,
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

  /// Local-only typing indicator.
  void setTypingStatus(String chatId, bool isTyping) {
    _isTyping = isTyping;
    _replaceChat(chatId, (chat) => chat.copyWith(isTyping: isTyping));
  }

  // ── sending ────────────────────────────────────────────────────────────

  /// [senderId] is accepted for call-site compatibility but ignored.
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

  /// Sends a recorded voice note.
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

  /// Sends a sticker — either a bundled gif asset ([assetPath]) or an.
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

  /// Shows the message straight away under a temporary id.
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
          // Nothing was stored, so a message pointing at it would be broken.
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

  /// Drops everything held for the account that just left.
  void clearForSignOut() {
    _chats.clear();
    _messagesByChatId.clear();
    _activeMessages.clear();
    _activeChatId = null;
    _hasLoadedChats = false;
    notifyListeners();
  }

  // ── realtime ───────────────────────────────────────────────────────────

  void _listenForMessages() {
    _messagesChannel = _service.subscribeToAllMessages(
      _onRemoteMessage,
      onUpdated: _onRemoteMessageChanged,
    );
    _profilesChannel = _service.subscribeToProfiles(_onProfileChanged);
    _presenceChannel = _service.subscribeToPresence((ids) {
      if (setEquals(ids, _onlineUserIds)) return;
      _onlineUserIds = ids;
      notifyListeners();
    });
  }

  /// Someone the user is talking to changed their name or photo.
  void _onProfileChanged(String userId, String? name, String? avatarUrl) {
    var touched = false;
    for (var i = 0; i < _chats.length; i++) {
      final chat = _chats[i];
      if (chat.otherUserId != userId) continue;
      if (chat.userImage == avatarUrl &&
          (name == null || name.trim().isEmpty || chat.userName == name)) {
        continue;
      }
      _chats[i] = chat.copyWith(
        userName: (name == null || name.trim().isEmpty) ? chat.userName : name,
        userImage: avatarUrl,
        clearUserImage: avatarUrl == null,
      );
      touched = true;
    }
    if (touched) notifyListeners();
  }

  /// A message the user already has changed on the server — in practice the
  /// other side opened the chat and its `is_read` flipped.
  void _onRemoteMessageChanged(ChatMessageModel message) {
    final messages = _messagesByChatId[message.chatId];
    if (messages == null) return;

    final index = messages.indexWhere((m) => m.id == message.id);
    if (index == -1 || messages[index].isRead == message.isRead) return;

    messages[index] = messages[index].copyWith(isRead: message.isRead);
    _syncActiveMessages(message.chatId);
    notifyListeners();
  }

  void _onRemoteMessage(ChatMessageModel message) {
    final me = _service.currentUserId;

    // The sender already has this one on screen from the optimistic insert.
    if (message.senderId == me) return;

    _appendMessage(message);
    if (message.chatId == _activeChatId && _appInForeground) {
      markConversationRead(message.chatId);
      return;
    }
    _replaceChat(
      message.chatId,
      (chat) => chat.copyWith(unreadCount: chat.unreadCount + 1),
    );
    _notify(message);
  }

  bool get _appInForeground =>
      WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;

  /// Puts the message in the notification tray, under the sender's name.
  void _notify(ChatMessageModel message) {
    final chat = chatById(message.chatId);
    final from = chat?.userName ?? 'New message';
    PushNotifications.instance.showMessage(
      // One notification per conversation rather than one per message.
      id: message.chatId.hashCode & 0x7fffffff,
      title: from,
      body: _previewFor(message),
    );
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
    final messages = _messagesByChatId.putIfAbsent(saved.chatId, () => []);
    final index = messages.indexWhere((m) => m.id == pendingId);

    if (index != -1) {
      messages[index] = saved;
    } else if (!messages.any((m) => m.id == saved.id)) {
      // The optimistic bubble is gone.
      messages.add(saved);
    }

    _syncActiveMessages(saved.chatId);
    notifyListeners();
  }

  void _removeMessage(String chatId, String messageId) {
    _messagesByChatId[chatId]?.removeWhere((m) => m.id == messageId);
    _syncActiveMessages(chatId);
    notifyListeners();
  }

  /// Applies [update] to one conversation in place.
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
