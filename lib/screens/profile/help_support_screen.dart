import 'package:flutter/material.dart';

/// A single message bubble in the support chat.
class _SupportMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  _SupportMessage({required this.text, required this.isUser, required this.time});
}

/// FAQ-driven, chatbot-styled support center. Bot replies are canned locally
/// today via [_SupportBot.reply]; swapping that method for a real API/AI
/// call is the only change needed for live support later.
class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

/// Canned response lookup — isolated so it can be swapped for a real
/// AI/API-backed implementation without touching the UI layer.
class _SupportBot {
  static const _responses = <String, String>{
    'rent a property':
        'Browse listings from the Search tab, tap a property you like to view its details, then use the Message or Contact Owner button to arrange a viewing.',
    'contact an owner':
        'Open any property\'s details page and tap the Message button — this starts a direct chat with that listing\'s owner.',
    'report a listing':
        'Open the listing and use Contact Us to flag it to our team with the reason. Our moderators review reports within 24 hours.',
    'payment':
        'DwellWise does not process rent payments directly — deposits and rent are arranged between you and the owner. For billing questions, reach out via Contact Us.',
    'account':
        'For login, verification, or profile issues, check Account & Security in your profile menu first. Still stuck? Email support@dwellwise.com.',
  };

  static String reply(String question) {
    final lower = question.toLowerCase();
    for (final entry in _responses.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return 'Thanks for reaching out! Our support team will get back to you shortly. For urgent matters, please use the Contact Us page.';
  }
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_SupportMessage> _messages = [];

  static const _quickQuestions = [
    'How do I rent a property?',
    'How do I contact an owner?',
    'How do I report a listing?',
    'Payment issues',
    'Account issues',
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(
      _SupportMessage(
        text: 'Hi! I\'m the DwellWise support bot. Ask a question below or tap one of the quick topics.',
        isUser: false,
        time: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _sendMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      _messages.add(_SupportMessage(text: trimmed, isUser: true, time: DateTime.now()));
    });
    _inputController.clear();
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _messages.add(_SupportMessage(text: _SupportBot.reply(trimmed), isUser: false, time: DateTime.now()));
      });
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Frequently Asked Questions',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _quickQuestions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final question = _quickQuestions[index];
                  return ActionChip(
                    label: Text(question),
                    onPressed: () => _sendMessage(question),
                  );
                },
              ),
            ),
            const Divider(height: 20),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return Align(
                    alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: message.isUser
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        message.text,
                        style: TextStyle(
                          color: message.isUser ? Colors.white : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        decoration: InputDecoration(
                          hintText: 'Type your question...',
                          filled: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        ),
                        onSubmitted: _sendMessage,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: () => _sendMessage(_inputController.text),
                      icon: const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
