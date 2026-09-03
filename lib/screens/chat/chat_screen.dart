import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_colors.dart';
import '../../config/app_strings.dart';
import '../../models/chat_message_model.dart';
import '../../models/chat_model.dart';
import '../../providers/chat_provider.dart';
import '../../services/chat_attachment_service.dart';
import '../../services/supabase_service.dart';
import '../../widgets/emoji_sticker_picker.dart';
import '../../widgets/voice_message_bubble.dart';

/// Messenger-style conversation screen for a single chat thread.
class ChatScreen extends StatefulWidget {
  final String chatId;

  const ChatScreen({
    super.key,
    required this.chatId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  /// Taken from the session.
  String get _currentUserId => _provider.currentUserId ?? '';

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocus = FocusNode();
  final ChatAttachmentService _attachments = ChatAttachmentService();

  int _lastRenderedMessageCount = -1;
  bool _showEmojiPicker = false;

  // Voice recording state.
  bool _isRecording = false;
  Duration _recordDuration = Duration.zero;
  Timer? _recordTimer;

  @override
  void initState() {
    super.initState();

    _inputFocus.addListener(() {
      if (_inputFocus.hasFocus && _showEmojiPicker) {
        setState(() => _showEmojiPicker = false);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      context.read<ChatProvider>().openConversation(widget.chatId);
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _attachments.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  ChatProvider get _provider => context.read<ChatProvider>();

  void _sendTextMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) {
      return;
    }

    _provider.sendMessage(widget.chatId, _currentUserId, text);
    _messageController.clear();
    _scrollToBottom();

    // The send is optimistic.
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      final error = _provider.lastSendError;
      if (error == null) return;
      _provider.lastSendError = null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Message not sent: $error'),
          backgroundColor: const Color(0xffDC2626),
        ),
      );
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // ── Emoji / stickers ────────────────────────────────────────────────────
  void _toggleEmojiPicker() {
    if (_showEmojiPicker) {
      setState(() => _showEmojiPicker = false);
      _inputFocus.requestFocus();
    } else {
      FocusScope.of(context).unfocus();
      setState(() => _showEmojiPicker = true);
    }
  }

  void _onStickerSelected(StickerItem sticker) {
    _provider.sendSticker(
      widget.chatId,
      _currentUserId,
      assetPath: sticker.assetPath,
      emoji: sticker.emoji,
    );
    _scrollToBottom();
  }

  // ── Attachments ─────────────────────────────────────────────────────────
  Future<void> _pickCamera() async {
    try {
      final photo = await _attachments.pickCameraPhoto();
      if (photo == null) return;
      _provider.sendAttachment(widget.chatId, _currentUserId,
          path: photo.path, fileName: photo.name, type: MessageType.image);
      _scrollToBottom();
    } catch (e) {
      _snack('Could not open camera: $e');
    }
  }

  Future<void> _pickGallery() async {
    try {
      final image = await _attachments.pickGalleryImage();
      if (image == null) return;
      _provider.sendAttachment(widget.chatId, _currentUserId,
          path: image.path, fileName: image.name, type: MessageType.image);
      _scrollToBottom();
    } catch (e) {
      _snack('Could not open gallery: $e');
    }
  }

  Future<void> _pickDocument() async {
    try {
      final doc = await _attachments.pickDocument();
      if (doc == null) return;
      final type =
          doc.name.toLowerCase().endsWith('.pdf') ? MessageType.pdf : MessageType.file;
      _provider.sendAttachment(widget.chatId, _currentUserId,
          path: doc.path, fileName: doc.name, type: type);
      _scrollToBottom();
    } catch (e) {
      _snack('Could not pick document: $e');
    }
  }

  Future<void> _shareLocation() async {
    _snack('Getting your location…');
    try {
      final pos = await _attachments.getCurrentLocation();
      _provider.sendLocation(widget.chatId, _currentUserId,
          latitude: pos.latitude, longitude: pos.longitude);
      _scrollToBottom();
    } on LocationException catch (e) {
      _snack(e.message);
    } catch (e) {
      _snack('Could not get location: $e');
    }
  }

  void _showAttachmentSheet() {
    FocusScope.of(context).unfocus();
    final theme = Theme.of(context);

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: theme.colorScheme.surface,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Share',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 20,
                  runSpacing: 18,
                  children: [
                    _AttachOption(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      color: const Color(0xffEF4444),
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        _pickCamera();
                      },
                    ),
                    _AttachOption(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      color: const Color(0xff8B5CF6),
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        _pickGallery();
                      },
                    ),
                    _AttachOption(
                      icon: Icons.picture_as_pdf_rounded,
                      label: 'Document',
                      color: const Color(0xff0EA5E9),
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        _pickDocument();
                      },
                    ),
                    _AttachOption(
                      icon: Icons.location_on_rounded,
                      label: 'Location',
                      color: const Color(0xff22C55E),
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        _shareLocation();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Voice recording ───────────────────────────────────────────────────────
  Future<void> _startRecording() async {
    FocusScope.of(context).unfocus();
    setState(() => _showEmojiPicker = false);
    try {
      final ok = await _attachments.startVoiceRecording();
      if (!ok) {
        _snack('Microphone permission is required for voice messages.');
        return;
      }
      setState(() {
        _isRecording = true;
        _recordDuration = Duration.zero;
      });
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          setState(() =>
              _recordDuration += const Duration(seconds: 1));
        }
      });
    } catch (e) {
      _snack('Could not start recording: $e');
    }
  }

  Future<void> _stopAndSendRecording() async {
    _recordTimer?.cancel();
    final recording = await _attachments.stopVoiceRecording();
    setState(() => _isRecording = false);
    if (recording == null) {
      _snack('Recording too short.');
      return;
    }
    _provider.sendVoiceMessage(widget.chatId, _currentUserId,
        path: recording.path, durationMs: recording.durationMs);
    _scrollToBottom();
  }

  Future<void> _cancelRecording() async {
    _recordTimer?.cancel();
    await _attachments.cancelVoiceRecording();
    setState(() => _isRecording = false);
  }

  // ── Conversation actions ──────────────────────────────────────────────────
  void _showMoreMenu(ChatModel? chat) {
    final theme = Theme.of(context);

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: theme.colorScheme.surface,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(chat?.isMuted == true
                    ? Icons.volume_up_outlined
                    : Icons.volume_off_outlined),
                title: Text(chat?.isMuted == true
                    ? 'Unmute conversation'
                    : 'Mute conversation'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _provider.muteConversation(
                      widget.chatId, !(chat?.isMuted ?? false));
                },
              ),
              ListTile(
                leading: const Icon(Icons.mark_chat_read_outlined),
                title: const Text('Mark as read'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _provider.markConversationRead(widget.chatId);
                },
              ),
              ListTile(
                leading: Icon(chat?.isPriority == true
                    ? Icons.push_pin
                    : Icons.push_pin_outlined),
                title: Text(chat?.isPriority == true
                    ? 'Remove priority'
                    : 'Mark as priority'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _provider.togglePriorityConversation(widget.chatId);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Delete conversation'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _provider.deleteConversation(widget.chatId);
                  context.pop();
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  /// Hands the number to the phone's own dialer rather than pretending to.
  Future<void> _callOtherParticipant(ChatModel? chat) async {
    var phone = chat?.otherUserPhone?.trim();

    // A thread opened straight from a listing is built locally and carries no
    // phone yet, so look it up before deciding there is none.
    if ((phone == null || phone.isEmpty) && chat?.otherUserId != null) {
      final profile =
          await SupabaseService().getOwnerProfile(chat!.otherUserId!);
      phone = (profile?['phone_number'] as String?)?.trim();
    }

    if (phone == null || phone.isEmpty) {
      _snack('This person has no phone number on their profile.');
      return;
    }

    final uri = Uri(scheme: 'tel', path: phone);
    if (!await launchUrl(uri)) {
      _snack('Could not open the dialer.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatProvider>();
    final opener = AppStrings.t(context, 'chat_opener');
    final theme = Theme.of(context);
    final chat = provider.chatById(widget.chatId);
    final isOtherOnline = provider.isUserOnline(chat?.otherUserId);
    final messages = provider.messagesForChat(widget.chatId);

    if (messages.length != _lastRenderedMessageCount) {
      _lastRenderedMessageCount = messages.length;
      _scrollToBottom();
    }

    final timelineEntries = _buildTimelineEntries(messages);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        titleSpacing: 0,
        leadingWidth: 40,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            _ThreadAvatar(chat: chat),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    chat?.userName ?? 'Conversation',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isOtherOnline
                              ? const Color(0xff22C55E)
                              : Colors.white54,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isOtherOnline ? 'Online' : 'Offline',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      if (chat?.isMuted == true) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.notifications_off_outlined,
                          size: 16,
                          color: Colors.white70,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Call',
            icon: const Icon(Icons.call_outlined),
            onPressed: () => _callOtherParticipant(chat),
          ),
          PopupMenuButton<String>(
            onSelected: (_) => _showMoreMenu(chat),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'mute', child: Text('Conversation actions')),
              PopupMenuItem(value: 'read', child: Text('Mark as read')),
              PopupMenuItem(value: 'priority', child: Text('Mark as priority')),
              PopupMenuItem(
                  value: 'delete', child: Text('Delete conversation')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? _EmptyThreadState(
                    userName: chat?.userName ?? 'This conversation')
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                    itemCount: timelineEntries.length,
                    itemBuilder: (context, index) {
                      final entry = timelineEntries[index];

                      if (entry.type == _TimelineEntryType.date) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: _DateSeparator(label: entry.label ?? ''),
                        );
                      }

                      final message = entry.message!;
                      final isMe = message.senderId == _currentUserId;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _MessageBubble(
                          message: message,
                          isMe: isMe,
                        ),
                      );
                    },
                  ),
          ),
          // Offered, not sent.
          if (messages.isEmpty)
            _SuggestedOpener(
              text: opener,
              onTap: () {
                // Uses the text computed during build. Working it out here
                // instead would read the locale through watch(), which is only
                // legal inside build and threw, so the tap did nothing.
                _messageController.text = opener;
                _sendTextMessage();
              },
            ),
          if (chat?.isTyping == true || provider.isTyping)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: _TypingIndicator(userName: chat?.userName ?? 'Typing'),
              ),
            ),
          _ComposerBar(
            controller: _messageController,
            focusNode: _inputFocus,
            isRecording: _isRecording,
            recordDuration: _recordDuration,
            emojiActive: _showEmojiPicker,
            onSend: _sendTextMessage,
            onEmojiTap: _toggleEmojiPicker,
            onAttachmentTap: _showAttachmentSheet,
            onCameraTap: _pickCamera,
            onLocationTap: _shareLocation,
            onStartRecording: _startRecording,
            onStopRecording: _stopAndSendRecording,
            onCancelRecording: _cancelRecording,
          ),
          if (_showEmojiPicker)
            EmojiStickerPicker(
              controller: _messageController,
              onStickerSelected: _onStickerSelected,
            ),
        ],
      ),
    );
  }

  List<_TimelineEntry> _buildTimelineEntries(List<ChatMessageModel> messages) {
    final entries = <_TimelineEntry>[];
    DateTime? previousDate;

    for (final message in messages) {
      final messageDate = DateTime(message.createdAt.year,
          message.createdAt.month, message.createdAt.day);
      if (previousDate == null || messageDate != previousDate) {
        entries.add(
          _TimelineEntry.date(_formatDateLabel(message.createdAt)),
        );
        previousDate = messageDate;
      }

      entries.add(_TimelineEntry.message(message));
    }

    return entries;
  }

  String _formatDateLabel(DateTime dateTime) {
    final today = DateTime.now();
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final current = DateTime(today.year, today.month, today.day);
    final difference = current.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    }

    if (difference == 1) {
      return 'Yesterday';
    }

    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

class _ThreadAvatar extends StatelessWidget {
  const _ThreadAvatar({required this.chat});

  final ChatModel? chat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = chat?.userName ?? 'C';
    final initial = name.isNotEmpty ? name.trim()[0].toUpperCase() : 'C';

    return CircleAvatar(
      radius: 18,
      backgroundColor: theme.colorScheme.primaryContainer,
      backgroundImage: chat?.userImage == null || chat!.userImage!.isEmpty
          ? null
          : NetworkImage(chat!.userImage!),
      child: chat?.userImage == null || chat!.userImage!.isEmpty
          ? Text(
              initial,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            )
          : null,
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isMe,
  });

  final ChatMessageModel message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Stickers render without a bubble background.
    if (message.type == MessageType.sticker) {
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            _StickerContent(message: message),
            const SizedBox(height: 4),
            _MetaRow(message: message, isMe: isMe, muted: true),
          ],
        ),
      );
    }

    final bubbleColor =
        isMe ? theme.colorScheme.primary : theme.colorScheme.surfaceVariant;
    final textColor =
        isMe ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.76),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isMe ? 18 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 18),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MessageContent(message: message, isMe: isMe, textColor: textColor),
              const SizedBox(height: 6),
              _MetaRow(message: message, isMe: isMe, color: textColor),
            ],
          ),
        ),
      ),
    );
  }
}

/// Renders the body of a message according to its [MessageType].
class _MessageContent extends StatelessWidget {
  const _MessageContent({
    required this.message,
    required this.isMe,
    required this.textColor,
  });

  final ChatMessageModel message;
  final bool isMe;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    switch (message.type) {
      case MessageType.image:
        return _ImageContent(path: message.attachmentUrl ?? '', tint: textColor);
      case MessageType.voice:
        return VoiceMessageBubble(
          path: message.attachmentUrl ?? '',
          durationMs: message.durationMs ?? 0,
          color: textColor,
        );
      case MessageType.location:
        return _LocationContent(
          latitude: message.latitude ?? 0,
          longitude: message.longitude ?? 0,
          tint: textColor,
        );
      case MessageType.pdf:
      case MessageType.file:
        return _DocContent(name: message.message, tint: textColor, type: message.type);
      case MessageType.sticker:
      case MessageType.text:
        return Text(
          message.message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w500,
            height: 1.35,
          ),
        );
    }
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.message,
    required this.isMe,
    this.color,
    this.muted = false,
  });

  final ChatMessageModel message;
  final bool isMe;
  final Color? color;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ??
        (muted ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.onSurface);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatTime(message.createdAt),
          style: theme.textTheme.labelSmall?.copyWith(
            color: c.withOpacity(0.72),
          ),
        ),
        if (isMe) ...[
          const SizedBox(width: 6),
          Icon(
            message.isRead ? Icons.done_all : Icons.done,
            size: 16,
            color: message.isRead ? Colors.white : c.withOpacity(0.72),
          ),
        ],
      ],
    );
  }
}

class _ImageContent extends StatelessWidget {
  const _ImageContent({required this.path, required this.tint});

  final String path;
  final Color tint;

  /// Uploaded attachments arrive as https urls; anything still on the device.
  bool get _isRemote => path.startsWith('http');

  Widget _thumbnail() {
    if (_isRemote) {
      return Image.network(path, fit: BoxFit.cover);
    }
    return Image.file(File(path), fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    final exists = path.isNotEmpty && (_isRemote || File(path).existsSync());

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: exists
          ? GestureDetector(
              // Tapping opens the photo full screen.
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => _FullScreenImage(path: path),
                ),
              ),
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(maxHeight: 240, maxWidth: 240),
                child: _thumbnail(),
              ),
            )
          : Container(
              width: 220,
              height: 150,
              color: tint.withOpacity(0.12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_outlined, color: tint, size: 36),
                  const SizedBox(height: 6),
                  Text('Photo',
                      style: TextStyle(color: tint, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
    );
  }
}

class _DocContent extends StatelessWidget {
  const _DocContent({required this.name, required this.tint, required this.type});

  final String name;
  final Color tint;
  final MessageType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tint.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tint.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            type == MessageType.pdf
                ? Icons.picture_as_pdf_rounded
                : Icons.insert_drive_file_rounded,
            color: tint,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              name.isEmpty ? 'Document' : name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: tint, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationContent extends StatelessWidget {
  const _LocationContent({
    required this.latitude,
    required this.longitude,
    required this.tint,
  });

  final double latitude;
  final double longitude;
  final Color tint;

  Future<void> _openMaps() async {
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _openMaps,
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 220,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 110,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  colors: [
                    tint.withOpacity(0.18),
                    tint.withOpacity(0.06),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Icon(Icons.location_on, color: tint, size: 44),
              ),
            ),
            const SizedBox(height: 8),
            Text('Shared location',
                style: TextStyle(color: tint, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(
              '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}',
              style: TextStyle(color: tint.withOpacity(0.8), fontSize: 11),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.map_outlined, size: 14, color: tint),
                const SizedBox(width: 4),
                Text('Open in Google Maps',
                    style: TextStyle(
                        color: tint,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StickerContent extends StatelessWidget {
  const _StickerContent({required this.message});

  final ChatMessageModel message;

  @override
  Widget build(BuildContext context) {
    final asset = message.attachmentUrl;
    if (asset != null && asset.isNotEmpty) {
      return SizedBox(
        width: 120,
        height: 120,
        child: Image.asset(asset, fit: BoxFit.contain),
      );
    }
    return Text(message.message, style: const TextStyle(fontSize: 64));
  }
}

class _AttachOption extends StatelessWidget {
  const _AttachOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: SizedBox(
        width: 64,
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: color.withOpacity(0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 6),
            Text(label,
                style: theme.textTheme.labelSmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _DateSeparator extends StatelessWidget {
  const _DateSeparator({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.75),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.7),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor:
                  AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$userName is typing...',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyThreadState extends StatelessWidget {
  const _EmptyThreadState({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Scrollable and trimmed.
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 56,
              color: theme.colorScheme.primary.withOpacity(0.4),
            ),
            const SizedBox(height: 14),
            Text(
              'Start the conversation with $userName',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComposerBar extends StatelessWidget {
  const _ComposerBar({
    required this.controller,
    required this.focusNode,
    required this.isRecording,
    required this.recordDuration,
    required this.emojiActive,
    required this.onSend,
    required this.onEmojiTap,
    required this.onAttachmentTap,
    required this.onCameraTap,
    required this.onLocationTap,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.onCancelRecording,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isRecording;
  final Duration recordDuration;
  final bool emojiActive;
  final VoidCallback onSend;
  final VoidCallback onEmojiTap;
  final VoidCallback onAttachmentTap;
  final VoidCallback onCameraTap;
  final VoidCallback onLocationTap;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;
  final VoidCallback onCancelRecording;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
              top: BorderSide(color: theme.dividerColor.withOpacity(0.25))),
        ),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: isRecording
            ? _RecordingBar(
                duration: recordDuration,
                onCancel: onCancelRecording,
                onSend: onStopRecording,
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Emoji & stickers',
                        onPressed: onEmojiTap,
                        icon: Icon(emojiActive
                            ? Icons.keyboard_outlined
                            : Icons.emoji_emotions_outlined),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant
                                .withOpacity(0.55),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: TextField(
                            controller: controller,
                            focusNode: focusNode,
                            minLines: 1,
                            maxLines: 4,
                            textInputAction: TextInputAction.newline,
                            decoration: const InputDecoration(
                              hintText: 'Write a message...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: onSend,
                        style: FilledButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(14),
                        ),
                        child: const Icon(Icons.send_rounded, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _ComposerActionButton(
                        icon: Icons.attach_file,
                        label: 'Attachment',
                        onTap: onAttachmentTap,
                      ),
                      _ComposerActionButton(
                        icon: Icons.camera_alt_outlined,
                        label: 'Camera',
                        onTap: onCameraTap,
                      ),
                      _ComposerActionButton(
                        icon: Icons.location_on_outlined,
                        label: 'Location',
                        onTap: onLocationTap,
                      ),
                      _ComposerActionButton(
                        icon: Icons.mic_none,
                        label: 'Voice',
                        onTap: onStartRecording,
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

class _RecordingBar extends StatelessWidget {
  const _RecordingBar({
    required this.duration,
    required this.onCancel,
    required this.onSend,
  });

  final Duration duration;
  final VoidCallback onCancel;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final m = duration.inMinutes.remainder(60).toString();
    final s = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Row(
      children: [
        IconButton(
          tooltip: 'Cancel',
          onPressed: onCancel,
          icon: const Icon(Icons.delete_outline, color: Color(0xffEF4444)),
        ),
        const _PulsingDot(),
        const SizedBox(width: 10),
        Text('Recording…  $m:$s',
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const Spacer(),
        FilledButton.icon(
          onPressed: onSend,
          icon: const Icon(Icons.send_rounded, size: 18),
          label: const Text('Send'),
        ),
      ],
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.3, end: 1.0).animate(_controller),
      child: Container(
        width: 12,
        height: 12,
        decoration: const BoxDecoration(
          color: Color(0xffEF4444),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _ComposerActionButton extends StatelessWidget {
  const _ComposerActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: TextButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: theme.colorScheme.primary),
        label: Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }
}

class _TimelineEntry {
  const _TimelineEntry.date(this.label)
      : type = _TimelineEntryType.date,
        message = null;

  const _TimelineEntry.message(this.message)
      : type = _TimelineEntryType.message,
        label = null;

  final _TimelineEntryType type;
  final String? label;
  final ChatMessageModel? message;
}

enum _TimelineEntryType { date, message }

String _formatTime(DateTime dateTime) {
  final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final period = dateTime.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $period';
}

/// A ready opening message shown above the composer on an empty thread.
class _SuggestedOpener extends StatelessWidget {
  const _SuggestedOpener({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: colors.primaryTint,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.primary.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(fontSize: 13, color: colors.primary),
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.send, size: 16, color: colors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-screen photo viewer, opened by tapping a photo in the thread.
class _FullScreenImage extends StatelessWidget {
  const _FullScreenImage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final image = path.startsWith('http')
        ? Image.network(path)
        : Image.file(File(path));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        // Pinch to zoom, drag to pan.
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: image,
        ),
      ),
    );
  }
}
