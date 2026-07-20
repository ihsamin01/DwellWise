import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../models/chat_message_model.dart';

/// Provider handling instant messaging conversations and attachment uploads.
class ChatProvider with ChangeNotifier {
  static const String _currentUserId = 'tenant1';
  static const String _otherUserId = 'owner1';

  final List<ChatModel> _chats = [];
  final Map<String, List<ChatMessageModel>> _messagesByChatId = {};

  final List<ChatMessageModel> _activeMessages = [];

  bool _isTyping = false;
  String _searchQuery = '';
  String? _activeChatId;
  bool _hasLoadedChats = false;

  List<ChatModel> get chats => _buildConversationList();

  List<ChatModel> get conversations => chats;

  List<ChatMessageModel> get activeMessages => _activeMessages;
  bool get isTyping => _isTyping;
  String get searchQuery => _searchQuery;
  String? get activeChatId => _activeChatId;

  int get unreadConversationCount =>
      _chats.where((chat) => chat.unreadCount > 0).length;

  void loadChats({bool forceReload = false}) {
    if (_hasLoadedChats && !forceReload) {
      notifyListeners();
      return;
    }

    final now = DateTime.now();
    _chats
      ..clear()
      ..addAll([
        ChatModel(
          id: '1',
          userName: 'Rahim Ahmed',
          userImage:
              'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=256&q=80',
          lastMessage: 'Is the apartment still available?',
          lastMessageTime: now.subtract(const Duration(minutes: 8)),
          unreadCount: 2,
          isMuted: false,
          isPriority: true,
          isOnline: true,
          lastMessageSenderId: _currentUserId,
          lastMessageType: 'text',
          messageCount: 8,
        ),
        ChatModel(
          id: '2',
          userName: 'Fatema Khan',
          userImage:
              'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=256&q=80',
          lastMessage: 'Thank you!',
          lastMessageTime: now.subtract(const Duration(hours: 3)),
          unreadCount: 0,
          isMuted: true,
          isPriority: false,
          isOnline: false,
          lastMessageSenderId: _otherUserId,
          lastMessageType: 'text',
          messageCount: 4,
        ),
        ChatModel(
          id: '3',
          userName: 'Nusrat Jahan',
          userImage:
              'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=256&q=80',
          lastMessage: 'Please share the floor plan PDF.',
          lastMessageTime: now.subtract(const Duration(minutes: 42)),
          unreadCount: 1,
          isMuted: false,
          isPriority: false,
          isOnline: true,
          isTyping: true,
          lastMessageSenderId: _otherUserId,
          lastMessageType: 'pdf',
          messageCount: 12,
        ),
      ]);

    _messagesByChatId
      ..clear()
      ..addAll({
        '1': [
          ChatMessageModel(
            id: 'm1',
            chatId: '1',
            senderId: _otherUserId,
            message:
                'Hello, is this penthouse available for visit this Friday?',
            isRead: true,
            createdAt: now.subtract(const Duration(hours: 2, minutes: 20)),
          ),
          ChatMessageModel(
            id: 'm2',
            chatId: '1',
            senderId: _currentUserId,
            message: 'Yes, it is still available.',
            isRead: true,
            createdAt: now.subtract(const Duration(hours: 2, minutes: 10)),
          ),
          ChatMessageModel(
            id: 'm3',
            chatId: '1',
            senderId: _otherUserId,
            message: 'Is the apartment still available?',
            isRead: false,
            createdAt: now.subtract(const Duration(minutes: 8)),
          ),
        ],
        '2': [
          ChatMessageModel(
            id: 'm4',
            chatId: '2',
            senderId: _currentUserId,
            message: 'I have sent the documents over email.',
            isRead: true,
            createdAt: now.subtract(const Duration(hours: 4)),
          ),
          ChatMessageModel(
            id: 'm5',
            chatId: '2',
            senderId: _otherUserId,
            message: 'Thank you!',
            isRead: false,
            createdAt: now.subtract(const Duration(hours: 3)),
          ),
        ],
        '3': [
          ChatMessageModel(
            id: 'm6',
            chatId: '3',
            senderId: _otherUserId,
            message: 'Please share the floor plan PDF.',
            isRead: false,
            createdAt: now.subtract(const Duration(minutes: 42)),
          ),
        ],
      });

    _hasLoadedChats = true;
    notifyListeners();
  }

  Future<void> refreshChats() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    loadChats(forceReload: true);
  }

  void searchConversations(String query) {
    _searchQuery = query.trim().toLowerCase();
    notifyListeners();
  }

  void clearSearch() {
    if (_searchQuery.isEmpty) {
      return;
    }

    _searchQuery = '';
    notifyListeners();
  }

  List<ChatMessageModel> messagesForChat(String chatId) {
    return List.unmodifiable(_messagesByChatId[chatId] ?? const []);
  }

  ChatModel? chatById(String chatId) {
    for (final chat in _chats) {
      if (chat.id == chatId) {
        return chat;
      }
    }
    return null;
  }

  void openConversation(String chatId) {
    _activeChatId = chatId;
    loadChatHistory(chatId);
    markConversationRead(chatId);
  }

  void deleteConversation(String chatId) {
    _chats.removeWhere((chat) => chat.id == chatId);
    _messagesByChatId.remove(chatId);

    if (_activeChatId == chatId) {
      _activeChatId = null;
      _activeMessages.clear();
    }

    notifyListeners();
  }

  void muteConversation(String chatId, bool muted) {
    _updateConversation(chatId, (chat) => chat.copyWith(isMuted: muted));
  }

  void togglePriorityConversation(String chatId) {
    final chat = chatById(chatId);
    if (chat == null) {
      return;
    }

    _updateConversation(
        chatId, (item) => item.copyWith(isPriority: !chat.isPriority));
  }

  void markConversationRead(String chatId) {
    final messages = _messagesByChatId[chatId];
    if (messages == null || messages.isEmpty) {
      _updateConversation(chatId, (chat) => chat.copyWith(unreadCount: 0));
      return;
    }

    for (var index = 0; index < messages.length; index += 1) {
      final message = messages[index];
      if (message.senderId != _currentUserId && !message.isRead) {
        messages[index] = ChatMessageModel(
          id: message.id,
          chatId: message.chatId,
          senderId: message.senderId,
          message: message.message,
          attachmentUrl: message.attachmentUrl,
          isRead: true,
          createdAt: message.createdAt,
        );
      }
    }

    _updateConversation(chatId, (chat) => chat.copyWith(unreadCount: 0));

    if (_activeChatId == chatId) {
      _syncActiveMessages(chatId);
    }

    notifyListeners();
  }

  void setTypingStatus(String chatId, bool isTyping) {
    _updateConversation(chatId, (chat) => chat.copyWith(isTyping: isTyping));
  }

  /// Loads conversation logs for matching room ID.
  void loadChatHistory(String chatId) {
    _activeChatId = chatId;
    final messages = _messagesByChatId[chatId];

    if (messages == null || messages.isEmpty) {
      _messagesByChatId[chatId] = [
        ChatMessageModel(
          id: 'seed-$chatId-1',
          chatId: chatId,
          senderId: _otherUserId,
          message: 'Hello, is this place still available?',
          isRead: false,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ];
    }

    _syncActiveMessages(chatId);
    notifyListeners();
  }

  /// Appends user message.
  void sendMessage(
    String chatId,
    String senderId,
    String text, {
    String? attachmentUrl,
  }) {
    final message = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: chatId,
      senderId: senderId,
      message: text,
      attachmentUrl: attachmentUrl,
      isRead: false,
      createdAt: DateTime.now(),
    );

    final messages = _messagesByChatId.putIfAbsent(chatId, () => []);
    messages.add(message);
    _syncActiveMessages(chatId);
    _updateConversationFromMessage(chatId, message);
    notifyListeners();

    // Trigger typing suggestion response simulation
    _simulateOwnerResponse(chatId);
  }

  Future<void> _simulateOwnerResponse(String chatId) async {
    _isTyping = true;
    setTypingStatus(chatId, true);
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    _isTyping = false;
    setTypingStatus(chatId, false);
    final message = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: chatId,
      senderId: _otherUserId,
      message: 'Sure, I have attached the flat outline map below.',
      attachmentUrl: 'Gulshan_Penthouse_FloorPlan.pdf',
      isRead: false,
      createdAt: DateTime.now(),
    );

    final messages = _messagesByChatId.putIfAbsent(chatId, () => []);
    messages.add(message);
    _syncActiveMessages(chatId);
    _updateConversationFromMessage(chatId, message);
    notifyListeners();
  }

  List<ChatModel> _buildConversationList() {
    final filteredChats = _searchQuery.isEmpty
        ? List<ChatModel>.from(_chats)
        : _chats.where((chat) {
            final query = _searchQuery;
            return chat.userName.toLowerCase().contains(query) ||
                chat.lastMessage.toLowerCase().contains(query);
          }).toList();

    filteredChats.sort((left, right) {
      if (left.isPriority != right.isPriority) {
        return left.isPriority ? -1 : 1;
      }

      final leftUnread = left.unreadCount > 0;
      final rightUnread = right.unreadCount > 0;
      if (leftUnread != rightUnread) {
        return leftUnread ? -1 : 1;
      }

      return right.lastMessageTime.compareTo(left.lastMessageTime);
    });

    return filteredChats;
  }

  void _updateConversation(
      String chatId, ChatModel Function(ChatModel chat) updater) {
    final index = _chats.indexWhere((chat) => chat.id == chatId);
    if (index == -1) {
      return;
    }

    _chats[index] = updater(_chats[index]);
    notifyListeners();
  }

  void _updateConversationFromMessage(String chatId, ChatMessageModel message) {
    final index = _chats.indexWhere((chat) => chat.id == chatId);
    final existingChat = index == -1 ? null : _chats[index];

    if (existingChat == null) {
      _chats.add(
        ChatModel(
          id: chatId,
          userName: 'New Conversation',
          lastMessage: message.message,
          lastMessageTime: message.createdAt,
          unreadCount: message.senderId == _currentUserId ? 0 : 1,
          isOnline: false,
          lastMessageSenderId: message.senderId,
          lastMessageType:
              message.attachmentUrl != null ? 'attachment' : 'text',
          messageCount: 1,
        ),
      );
      return;
    }

    final updatedUnreadCount = message.senderId == _currentUserId
        ? existingChat.unreadCount
        : existingChat.unreadCount + 1;

    _chats[index] = existingChat.copyWith(
      lastMessage: message.attachmentUrl != null && message.message.isEmpty
          ? 'Attachment'
          : message.message,
      lastMessageTime: message.createdAt,
      unreadCount: updatedUnreadCount,
      isTyping: false,
      lastMessageSenderId: message.senderId,
      lastMessageType: message.attachmentUrl != null ? 'attachment' : 'text',
      messageCount: existingChat.messageCount + 1,
    );
  }

  void _syncActiveMessages(String chatId) {
    _activeMessages
      ..clear()
      ..addAll(_messagesByChatId[chatId] ?? const []);
  }
}
