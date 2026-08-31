import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../providers/assistant_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/property_matcher.dart';
import '../../widgets/voice_input_button.dart';

/// Conversational way into the app for someone who does not want to learn the.
class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AssistantProvider>().loadRecent();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();

    final address = context.read<UserProvider>().userModel?.address;
    context.read<AssistantProvider>().send(text, profileAddress: address);

    // After the frame the new bubble is laid out, so the offset is real.
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final assistant = context.watch<AssistantProvider>();
    final messages = assistant.messages;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colors.background,
      endDrawer: _HistoryPanel(colors: colors),
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.auto_awesome, color: colors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'DwellWise Assistant',
              style: TextStyle(
                color: colors.primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'History',
            icon: Icon(Icons.add_comment_outlined, color: colors.primary),
            onPressed: () {
              context.read<AssistantProvider>().loadRecent();
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? _EmptyState(colors: colors)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) =>
                        _MessageBubble(message: messages[index], colors: colors),
                  ),
          ),
          _Composer(
            controller: _controller,
            colors: colors,
            enabled: !assistant.isBusy,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

/// Shown before the first message.
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      children: [
        Icon(Icons.auto_awesome, size: 56, color: colors.primary),
        const SizedBox(height: 16),
        Text(
          'Tell me what you are looking for',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'বাংলা বা English — যেভাবে খুশি বলুন',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: colors.textSecondary),
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.colors});

  final AssistantMessage message;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, left: 48),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            message.text,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 8, right: 48),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.border),
          ),
          child: message.isPending
              ? _TypingDots(colors: colors)
              : Text(
                  message.text,
                  style: TextStyle(fontSize: 14, color: colors.textPrimary),
                ),
        ),
        if (message.requirements != null && !message.isPending)
          _RequirementChips(
              intent: message.requirements!, colors: colors),
        for (final match in message.matches)
          _PropertyResultCard(match: match, colors: colors),
        if (message.cheaperNearby.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 6),
            child: Text(
              'Cheaper nearby',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colors.textSecondary,
              ),
            ),
          ),
          for (final match in message.cheaperNearby)
            _PropertyResultCard(match: match, colors: colors),
        ],
        const SizedBox(height: 8),
      ],
    );
  }
}

/// What the assistant understood.
class _RequirementChips extends StatelessWidget {
  const _RequirementChips({required this.intent, required this.colors});

  final SearchIntent intent;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final chips = <String>[
      if (intent.area != null) intent.area!,
      if (intent.propertyType != null) intent.propertyType!,
      if (intent.beds != null) '${intent.beds} bed',
      if (intent.baths != null) '${intent.baths} bath',
      if (intent.balcony != null) '${intent.balcony} balcony',
      if (intent.maxRent != null) 'under ৳${intent.maxRent!.round()}',
      ...intent.facilities.map((f) => f.toLowerCase()),
    ];
    if (chips.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10, right: 48),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final chip in chips)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colors.primaryTint,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                chip,
                style: TextStyle(fontSize: 11, color: colors.primary),
              ),
            ),
        ],
      ),
    );
  }
}

/// A real listing, tappable through to its details page.
class _PropertyResultCard extends StatelessWidget {
  const _PropertyResultCard({required this.match, required this.colors});

  final MatchResult match;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final property = match.property;

    return GestureDetector(
      onTap: () => context.push('/property/${property.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8, right: 24),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${property.beds} bed · ${property.baths} bath · ${property.area}',
                    style:
                        TextStyle(fontSize: 12, color: colors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '৳${property.price.round()}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (match.isOverBudget)
                        Text(
                          '৳${match.overBudgetBy!.round()} over',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xffDC2626),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _TypingDots extends StatelessWidget {
  const _TypingDots({required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 16,
      child: Center(
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(colors.textSecondary),
          ),
        ),
      ),
    );
  }
}

class _Composer extends StatefulWidget {
  const _Composer({
    required this.controller,
    required this.colors,
    required this.enabled,
    required this.onSend,
  });

  final TextEditingController controller;
  final AppColors colors;
  final bool enabled;
  final VoidCallback onSend;

  @override
  State<_Composer> createState() => _ComposerState();
}

class _ComposerState extends State<_Composer> {
  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final colors = widget.colors;
    final enabled = widget.enabled;
    final onSend = widget.onSend;
    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        8,
        12,
        8 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              style: TextStyle(color: colors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'কী ধরনের বাসা খুঁজছেন?',
                hintStyle:
                    TextStyle(color: colors.textSecondary, fontSize: 14),
                filled: true,
                fillColor: colors.background,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: colors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: colors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: colors.primary),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          VoiceInputButton(
            colors: colors,
            enabled: enabled,
            onResult: (text) {
              // Dictation writes into the same field typing uses.
              controller.value = TextEditingValue(
                text: text,
                selection: TextSelection.collapsed(offset: text.length),
              );
            },
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: enabled ? onSend : null,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: enabled ? colors.primary : colors.border,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_upward,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

/// Past conversations, opened from the app bar.
class _HistoryPanel extends StatelessWidget {
  const _HistoryPanel({required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final assistant = context.watch<AssistantProvider>();
    final recent = assistant.recent;

    return Drawer(
      backgroundColor: colors.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Text(
                    'Chats',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      context.read<AssistantProvider>().reset();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('New'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: recent.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'No past chats yet.',
                          style: TextStyle(color: colors.textSecondary),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: recent.length,
                      itemBuilder: (context, index) {
                        final chat = recent[index];
                        final active = chat.id == assistant.conversationId;

                        return ListTile(
                          selected: active,
                          selectedTileColor: colors.primaryTint,
                          leading: Icon(Icons.chat_bubble_outline,
                              size: 18, color: colors.textSecondary),
                          title: Text(
                            chat.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.textPrimary,
                            ),
                          ),
                          trailing: IconButton(
                            tooltip: 'Delete',
                            icon: Icon(Icons.delete_outline,
                                size: 18, color: colors.textSecondary),
                            onPressed: () => context
                                .read<AssistantProvider>()
                                .deleteConversation(chat.id),
                          ),
                          onTap: () {
                            context
                                .read<AssistantProvider>()
                                .openConversation(chat.id);
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
