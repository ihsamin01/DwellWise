import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/chat_provider.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadChats();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    await context.read<ChatProvider>().refreshChats();
  }

  void _openChat(String chatId) {
    context.read<ChatProvider>().openConversation(chatId);
    context.push('/chat/$chatId');
  }

  void _showConversationActions(BuildContext context, _ConversationItem item) {
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
                leading: const Icon(Icons.delete_outline),
                title: const Text('Delete Conversation'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  provider.deleteConversation(item.chat.id);
                },
              ),
              ListTile(
                leading: Icon(item.chat.isMuted
                    ? Icons.volume_up_outlined
                    : Icons.volume_off_outlined),
                title: Text(item.chat.isMuted ? 'Unmute' : 'Mute'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  provider.muteConversation(item.chat.id, !item.chat.isMuted);
                },
              ),
              ListTile(
                leading: Icon(item.chat.isPriority
                    ? Icons.push_pin
                    : Icons.push_pin_outlined),
                title: Text(item.chat.isPriority
                    ? 'Remove Priority'
                    : 'Mark as Priority'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  provider.togglePriorityConversation(item.chat.id);
                },
              ),
              ListTile(
                leading: const Icon(Icons.mark_chat_read_outlined),
                title: const Text('Mark as Read'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  provider.markConversationRead(item.chat.id);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatProvider>();
    final theme = Theme.of(context);
    final conversations = provider.chats;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Messages'),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${provider.unreadConversationCount}',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: theme.dividerColor.withOpacity(0.3)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: provider.searchConversations,
                      decoration: InputDecoration(
                        hintText: 'Search conversations',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: provider.searchQuery.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  provider.clearSearch();
                                },
                              ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                      ),
                    ),
                  ),
                ),
              ),
              if (conversations.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyConversationState(
                    hasQuery: provider.searchQuery.isNotEmpty,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                  sliver: SliverList.separated(
                    itemCount: conversations.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final chat = conversations[index];
                      final item = _ConversationItem(chat: chat);

                      return Dismissible(
                        key: ValueKey(chat.id),
                        direction: DismissDirection.horizontal,
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            provider.muteConversation(chat.id, !chat.isMuted);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(chat.isMuted
                                    ? '${chat.userName} unmuted'
                                    : '${chat.userName} muted'),
                              ),
                            );
                            return false;
                          }

                          if (direction == DismissDirection.endToStart) {
                            provider.deleteConversation(chat.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('${chat.userName} deleted')),
                            );
                            return true;
                          }

                          return false;
                        },
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(Icons.volume_off_outlined),
                        ),
                        secondaryBackground: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(Icons.delete_outline),
                        ),
                        child: Material(
                          color: theme.colorScheme.surface,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () => _openChat(chat.id),
                            onLongPress: () =>
                                _showConversationActions(context, item),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                    color:
                                        theme.dividerColor.withOpacity(0.25)),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.shadowColor.withOpacity(0.04),
                                    blurRadius: 14,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  _ConversationAvatar(chat: chat),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                chat.userName,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: theme
                                                    .textTheme.titleMedium
                                                    ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              _formatConversationTime(
                                                  chat.lastMessageTime),
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                color: theme.colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                chat.isTyping
                                                    ? 'typing...'
                                                    : _messagePreview(chat),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: theme
                                                    .textTheme.bodyMedium
                                                    ?.copyWith(
                                                  color: chat.unreadCount > 0
                                                      ? theme
                                                          .colorScheme.onSurface
                                                      : theme.colorScheme
                                                          .onSurfaceVariant,
                                                  fontWeight:
                                                      chat.unreadCount > 0
                                                          ? FontWeight.w600
                                                          : FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                            if (chat.isMuted) ...[
                                              const SizedBox(width: 8),
                                              Icon(
                                                Icons
                                                    .notifications_off_outlined,
                                                size: 18,
                                                color: theme.colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ],
                                            if (chat.unreadCount > 0) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                  color:
                                                      theme.colorScheme.primary,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          999),
                                                ),
                                                child: Text(
                                                  chat.unreadCount.toString(),
                                                  style: theme
                                                      .textTheme.labelSmall
                                                      ?.copyWith(
                                                    color: theme
                                                        .colorScheme.onPrimary,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConversationItem {
  const _ConversationItem({required this.chat});

  final dynamic chat;
}

class _ConversationAvatar extends StatelessWidget {
  const _ConversationAvatar({required this.chat});

  final dynamic chat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials =
        chat.userName.isNotEmpty ? chat.userName.trim()[0].toUpperCase() : '?';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: theme.colorScheme.primaryContainer,
          backgroundImage: chat.userImage == null || chat.userImage!.isEmpty
              ? null
              : NetworkImage(chat.userImage!),
          child: chat.userImage == null || chat.userImage!.isEmpty
              ? Text(
                  initials,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                )
              : null,
        ),
        Positioned(
          right: 1,
          bottom: 1,
          child: Container(
            width: 13,
            height: 13,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: chat.isOnline
                  ? const Color(0xff22C55E)
                  : theme.colorScheme.outline,
              border: Border.all(color: theme.colorScheme.surface, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyConversationState extends StatelessWidget {
  const _EmptyConversationState({required this.hasQuery});

  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasQuery ? Icons.search_off : Icons.forum_outlined,
              size: 72,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              hasQuery ? 'No conversations found' : 'No conversations yet',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasQuery
                  ? 'Try a different search term.'
                  : 'When someone messages you, the inbox will appear here.',
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

String _messagePreview(dynamic chat) {
  if (chat.lastMessageType == 'attachment') {
    return 'Attachment';
  }

  return chat.lastMessage.isEmpty ? 'No messages yet' : chat.lastMessage;
}

String _formatConversationTime(DateTime time) {
  final now = DateTime.now();
  final difference = now.difference(time);

  if (difference.inDays > 6) {
    return '${time.day}/${time.month}';
  }

  if (difference.inDays > 0) {
    return '${difference.inDays}d';
  }

  if (difference.inHours > 0) {
    return '${difference.inHours}h';
  }

  if (difference.inMinutes > 0) {
    return '${difference.inMinutes}m';
  }

  return 'now';
}
