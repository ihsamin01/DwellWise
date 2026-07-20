class ChatModel {
  final String id;
  final String userName;
  final String? userImage;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isMuted;
  final bool isPriority;
  final bool isOnline;
  final bool isTyping;
  final String? lastMessageSenderId;
  final String? lastMessageType;
  final int messageCount;

  const ChatModel({
    required this.id,
    required this.userName,
    this.userImage,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isMuted = false,
    this.isPriority = false,
    this.isOnline = false,
    this.isTyping = false,
    this.lastMessageSenderId,
    this.lastMessageType,
    this.messageCount = 0,
  });

  ChatModel copyWith({
    String? id,
    String? userName,
    String? userImage,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    bool? isMuted,
    bool? isPriority,
    bool? isOnline,
    bool? isTyping,
    String? lastMessageSenderId,
    String? lastMessageType,
    int? messageCount,
  }) {
    return ChatModel(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      userImage: userImage ?? this.userImage,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isMuted: isMuted ?? this.isMuted,
      isPriority: isPriority ?? this.isPriority,
      isOnline: isOnline ?? this.isOnline,
      isTyping: isTyping ?? this.isTyping,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      lastMessageType: lastMessageType ?? this.lastMessageType,
      messageCount: messageCount ?? this.messageCount,
    );
  }

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] as String,
      userName: json['user_name'] as String? ?? '',
      userImage: json['user_image'] as String?,
      lastMessage: json['last_message'] as String? ?? '',
      lastMessageTime:
          DateTime.tryParse(json['last_message_time'] as String? ?? '') ??
              DateTime.now(),
      unreadCount: json['unread_count'] as int? ?? 0,
      isMuted: json['is_muted'] as bool? ?? false,
      isPriority: json['is_priority'] as bool? ?? false,
      isOnline: json['is_online'] as bool? ?? false,
      isTyping: json['is_typing'] as bool? ?? false,
      lastMessageSenderId: json['last_message_sender_id'] as String?,
      lastMessageType: json['last_message_type'] as String?,
      messageCount: json['message_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_name': userName,
      'user_image': userImage,
      'last_message': lastMessage,
      'last_message_time': lastMessageTime.toIso8601String(),
      'unread_count': unreadCount,
      'is_muted': isMuted,
      'is_priority': isPriority,
      'is_online': isOnline,
      'is_typing': isTyping,
      'last_message_sender_id': lastMessageSenderId,
      'last_message_type': lastMessageType,
      'message_count': messageCount,
    };
  }
}
