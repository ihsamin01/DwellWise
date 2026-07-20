import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/chat_message_model.dart';
import '../../models/chat_model.dart';
import '../../providers/chat_provider.dart';

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
  static const String _currentUserId = 'tenant1';

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _lastRenderedMessageCount = -1;

  @override
  void initState() {
    super.initState();

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
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendTextMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) {
      return;
    }

    context
        .read<ChatProvider>()
        .sendMessage(widget.chatId, _currentUserId, text);
    _messageController.clear();
    _scrollToBottom();
  }

  void _sendAttachmentMessage(
      {required String label, required String attachmentUrl}) {
    context.read<ChatProvider>().sendMessage(
          widget.chatId,
          _currentUserId,
          label,
          attachmentUrl: attachmentUrl,
        );
    _scrollToBottom();
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

  void _showAttachmentSheet() {
    final provider = context.read<ChatProvider>();
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
                leading: const Icon(Icons.image_outlined),
                title: const Text('Send image'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  provider.sendMessage(widget.chatId, _currentUserId, 'Photo',
                      attachmentUrl: 'photo.jpg');
                  _scrollToBottom();
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_outlined),
                title: const Text('Send PDF'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  provider.sendMessage(
                      widget.chatId, _currentUserId, 'Document',
                      attachmentUrl: 'document.pdf');
                  _scrollToBottom();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Open camera'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  provider.sendMessage(
                      widget.chatId, _currentUserId, 'Camera photo',
                      attachmentUrl: 'camera.jpg');
                  _scrollToBottom();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Open gallery'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  provider.sendMessage(
                      widget.chatId, _currentUserId, 'Gallery image',
                      attachmentUrl: 'gallery.jpg');
                  _scrollToBottom();
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _showMoreMenu(ChatModel? chat) {
    final provider = context.read<ChatProvider>();
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
                  provider.muteConversation(
                      widget.chatId, !(chat?.isMuted ?? false));
                },
              ),
              ListTile(
                leading: const Icon(Icons.mark_chat_read_outlined),
                title: const Text('Mark as read'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  provider.markConversationRead(widget.chatId);
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
                  provider.togglePriorityConversation(widget.chatId);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Delete conversation'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  provider.deleteConversation(widget.chatId);
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

  void _showCallPlaceholder(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label is not connected yet.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatProvider>();
    final theme = Theme.of(context);
    final chat = provider.chatById(widget.chatId);
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
                          color: chat?.isOnline == true
                              ? const Color(0xff22C55E)
                              : theme.colorScheme.outline,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        chat?.isOnline == true ? 'Active now' : 'Offline',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (chat?.isMuted == true) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
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
            tooltip: 'Voice call',
            icon: const Icon(Icons.call_outlined),
            onPressed: () => _showCallPlaceholder('Voice call'),
          ),
          IconButton(
            tooltip: 'Video call',
            icon: const Icon(Icons.videocam_outlined),
            onPressed: () => _showCallPlaceholder('Video call'),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'mute':
                case 'read':
                case 'priority':
                case 'delete':
                  _showMoreMenu(chat);
                  break;
              }
            },
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
            onSend: _sendTextMessage,
            onEmojiTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Emoji picker is not connected yet.')),
            ),
            onAttachmentTap: _showAttachmentSheet,
            onCameraTap: () => _sendAttachmentMessage(
                label: 'Camera photo', attachmentUrl: 'camera.jpg'),
            onGalleryTap: () => _sendAttachmentMessage(
                label: 'Gallery image', attachmentUrl: 'gallery.jpg'),
            onMicTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content:
                      Text('Voice message recording is not connected yet.')),
            ),
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
              if (message.attachmentUrl != null) ...[
                _AttachmentPreview(
                  attachmentUrl: message.attachmentUrl!,
                  isMe: isMe,
                ),
                if (message.message.isNotEmpty) const SizedBox(height: 8),
              ],
              if (message.message.isNotEmpty)
                Text(
                  message.message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(message.createdAt),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: textColor.withOpacity(0.72),
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 6),
                    Icon(
                      message.isRead ? Icons.done_all : Icons.done,
                      size: 15,
                      color: message.isRead
                          ? const Color(0xff60A5FA)
                          : textColor.withOpacity(0.72),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      message.isRead ? 'Seen' : 'Sent',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: textColor.withOpacity(0.72),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttachmentPreview extends StatelessWidget {
  const _AttachmentPreview({
    required this.attachmentUrl,
    required this.isMe,
  });

  final String attachmentUrl;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isImage = _isImageAttachment(attachmentUrl);
    final attachmentColor =
        isMe ? theme.colorScheme.onPrimary : theme.colorScheme.primary;

    if (isImage) {
      return Container(
        width: 220,
        height: 150,
        decoration: BoxDecoration(
          color: attachmentColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, color: attachmentColor, size: 36),
            const SizedBox(height: 8),
            Text(
              attachmentUrl,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium?.copyWith(
                color: attachmentColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: attachmentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: attachmentColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            attachmentUrl.toLowerCase().endsWith('.pdf')
                ? Icons.picture_as_pdf_outlined
                : Icons.attach_file,
            color: attachmentColor,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              attachmentUrl,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: attachmentColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 72,
              color: theme.colorScheme.primary.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Start the conversation with $userName',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Send a message, image, or document to begin the thread.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
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
    required this.onSend,
    required this.onEmojiTap,
    required this.onAttachmentTap,
    required this.onCameraTap,
    required this.onGalleryTap,
    required this.onMicTap,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onEmojiTap;
  final VoidCallback onAttachmentTap;
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;
  final VoidCallback onMicTap;

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Emoji',
                  onPressed: onEmojiTap,
                  icon: const Icon(Icons.emoji_emotions_outlined),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: TextField(
                      controller: controller,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => onSend(),
                      decoration: const InputDecoration(
                        hintText: 'Write a message...',
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  icon: Icons.photo_library_outlined,
                  label: 'Gallery',
                  onTap: onGalleryTap,
                ),
                _ComposerActionButton(
                  icon: Icons.mic_none,
                  label: 'Voice',
                  onTap: onMicTap,
                ),
              ],
            ),
          ],
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

bool _isImageAttachment(String attachmentUrl) {
  final lower = attachmentUrl.toLowerCase();
  return lower.endsWith('.jpg') ||
      lower.endsWith('.jpeg') ||
      lower.endsWith('.png') ||
      lower.endsWith('.webp') ||
      lower.endsWith('.gif');
}
