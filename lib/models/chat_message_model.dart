/// The kind of content a chat message carries. Drives how the bubble renders.
enum MessageType { text, image, pdf, file, voice, location, sticker }

MessageType messageTypeFromString(String? value) {
  switch (value) {
    case 'image':
      return MessageType.image;
    case 'pdf':
      return MessageType.pdf;
    case 'file':
      return MessageType.file;
    case 'voice':
      return MessageType.voice;
    case 'location':
      return MessageType.location;
    case 'sticker':
      return MessageType.sticker;
    case 'text':
    default:
      return MessageType.text;
  }
}

/// Data model representing an instant message between tenant and owner.
class ChatMessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String message;

  /// Local file path or remote URL for image / pdf / file / voice / sticker
  /// attachments. Null for plain text and location messages.
  final String? attachmentUrl;

  /// Discriminates how the bubble should render the message.
  final MessageType type;

  /// Voice note length in milliseconds ([type] == voice).
  final int? durationMs;

  /// Coordinates for a shared location ([type] == location).
  final double? latitude;
  final double? longitude;

  final bool isRead;
  final DateTime createdAt;

  ChatMessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.message,
    this.attachmentUrl,
    this.type = MessageType.text,
    this.durationMs,
    this.latitude,
    this.longitude,
    required this.isRead,
    required this.createdAt,
  });

  bool get hasAttachment => attachmentUrl != null && attachmentUrl!.isNotEmpty;

  ChatMessageModel copyWith({bool? isRead}) {
    return ChatMessageModel(
      id: id,
      chatId: chatId,
      senderId: senderId,
      message: message,
      attachmentUrl: attachmentUrl,
      type: type,
      durationMs: durationMs,
      latitude: latitude,
      longitude: longitude,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  /// Factory constructor to parse ChatMessageModel from JSON.
  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      chatId: json['chat_id'] as String,
      senderId: json['sender_id'] as String,
      message: json['message'] as String? ?? '',
      attachmentUrl: json['attachment_url'] as String?,
      type: messageTypeFromString(json['type'] as String?),
      durationMs: json['duration_ms'] as int?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Converts ChatMessageModel to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'sender_id': senderId,
      'message': message,
      'attachment_url': attachmentUrl,
      'type': type.name,
      'duration_ms': durationMs,
      'latitude': latitude,
      'longitude': longitude,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
