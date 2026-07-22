import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_strings.dart';
import '../../providers/locale_provider.dart';

/// A single preset FAQ entry with English and Bangla copy.
class _FaqEntry {
  final String questionEn;
  final String questionBn;
  final String answerEn;
  final String answerBn;

  const _FaqEntry({
    required this.questionEn,
    required this.questionBn,
    required this.answerEn,
    required this.answerBn,
  });

  String question(bool isBangla) => isBangla ? questionBn : questionEn;
  String answer(bool isBangla) => isBangla ? answerBn : answerEn;
}

/// A category of FAQ entries (e.g. House Rent, House Listing).
class _FaqCategory {
  final String titleEn;
  final String titleBn;
  final List<_FaqEntry> entries;

  const _FaqCategory({
    required this.titleEn,
    required this.titleBn,
    required this.entries,
  });

  String title(bool isBangla) => isBangla ? titleBn : titleEn;
}

const _faqCategories = <_FaqCategory>[
  _FaqCategory(
    titleEn: 'House Rent',
    titleBn: 'বাসা ভাড়া',
    entries: [
      _FaqEntry(
        questionEn: 'How do I rent a property?',
        questionBn: 'আমি কীভাবে একটি বাসা ভাড়া নেব?',
        answerEn:
            'Go to the Search tab, select your Division, District, Thana and Area, then tap Search. Open any listing you like and tap Message or Contact Owner to arrange a viewing.',
        answerBn:
            'সার্চ ট্যাবে গিয়ে আপনার বিভাগ, জেলা, থানা ও এলাকা নির্বাচন করে Search চাপুন। পছন্দের লিস্টিং খুলে Message অথবা Contact Owner চেপে বাড়িওয়ালার সাথে যোগাযোগ করুন।',
      ),
      _FaqEntry(
        questionEn: 'How do I contact a property owner?',
        questionBn: 'আমি কীভাবে বাড়িওয়ালার সাথে যোগাযোগ করব?',
        answerEn:
            'Open the property\'s details page and tap the Message button — this starts a direct chat with that listing\'s owner inside the app.',
        answerBn:
            'লিস্টিং-এর বিস্তারিত পেজে গিয়ে Message বাটনে চাপুন — এতে ওই বাড়ির মালিকের সাথে সরাসরি চ্যাট শুরু হবে।',
      ),
      _FaqEntry(
        questionEn: 'What should I check before renting?',
        questionBn: 'ভাড়া নেওয়ার আগে কী কী যাচাই করা উচিত?',
        answerEn:
            'Verify the owner\'s identity, visit the property in person if possible, check the "Verified" badge on the listing, and confirm rent, advance, and utility terms in writing before paying anything.',
        answerBn:
            'বাড়িওয়ালার পরিচয় যাচাই করুন, সম্ভব হলে সরাসরি বাসা দেখে আসুন, লিস্টিং-এ "Verified" ব্যাজ আছে কিনা দেখুন, এবং টাকা দেওয়ার আগে ভাড়া, অগ্রিম ও ইউটিলিটি বিল সংক্রান্ত শর্তাবলী লিখিতভাবে নিশ্চিত করুন।',
      ),
      _FaqEntry(
        questionEn: 'How does the advance/deposit work?',
        questionBn: 'অগ্রিম/জামানত কীভাবে কাজ করে?',
        answerEn:
            'DwellWise does not collect or hold any advance or deposit. Any advance payment is arranged and paid directly between you and the property owner — always get a receipt.',
        answerBn:
            'DwellWise কোনো অগ্রিম বা জামানত সংগ্রহ করে না বা নিজের কাছে রাখে না। যেকোনো অগ্রিম পেমেন্ট সরাসরি আপনার ও বাড়িওয়ালার মধ্যে হয় — সবসময় রসিদ নিয়ে রাখুন।',
      ),
    ],
  ),
  _FaqCategory(
    titleEn: 'House Listing',
    titleBn: 'বাড়ি লিস্টিং',
    entries: [
      _FaqEntry(
        questionEn: 'How do I list my property?',
        questionBn: 'আমি কীভাবে আমার বাড়ি লিস্ট করব?',
        answerEn:
            'Switch to Landlord view from your profile, then tap "Add Property" and fill in the details, photos, and rent amount to publish your listing.',
        answerBn:
            'প্রোফাইল থেকে Landlord ভিউতে সুইচ করুন, এরপর "Add Property"-তে চেপে বিবরণ, ছবি ও ভাড়ার পরিমাণ দিয়ে আপনার লিস্টিং প্রকাশ করুন।',
      ),
      _FaqEntry(
        questionEn: 'How do I edit or remove my listing?',
        questionBn: 'আমি কীভাবে আমার লিস্টিং এডিট বা মুছে ফেলব?',
        answerEn:
            'Go to My Properties from your Landlord dashboard, open the listing you want to change, and use the Edit or Remove option there.',
        answerBn:
            'Landlord ড্যাশবোর্ড থেকে My Properties-এ যান, যে লিস্টিংটি পরিবর্তন করতে চান সেটি খুলুন, এবং সেখান থেকে Edit বা Remove অপশন ব্যবহার করুন।',
      ),
      _FaqEntry(
        questionEn: 'How do I get my listing verified?',
        questionBn: 'আমার লিস্টিং কীভাবে ভেরিফাই করাবো?',
        answerEn:
            'Submit clear property photos and accurate address details when creating your listing. Our team reviews new listings and adds the "Verified" badge once confirmed.',
        answerBn:
            'লিস্টিং তৈরি করার সময় স্পষ্ট ছবি ও সঠিক ঠিকানা দিন। আমাদের টিম নতুন লিস্টিং পর্যালোচনা করে নিশ্চিত হলে "Verified" ব্যাজ যুক্ত করে দেয়।',
      ),
      _FaqEntry(
        questionEn: 'How do I report a fake listing?',
        questionBn: 'আমি কীভাবে ভুয়া লিস্টিং রিপোর্ট করব?',
        answerEn:
            'Open the listing and use the Contact Us page to report it with the reason. Our moderation team reviews all reports within 24 hours.',
        answerBn:
            'লিস্টিংটি খুলে Contact Us পেজ থেকে কারণসহ রিপোর্ট করুন। আমাদের মডারেশন টিম ২৪ ঘণ্টার মধ্যে সব রিপোর্ট পর্যালোচনা করে।',
      ),
    ],
  ),
];

/// A single message bubble in the support chat.
class _SupportMessage {
  final String text;
  final bool isUser;

  _SupportMessage({required this.text, required this.isUser});
}

/// Chatbot-styled support center — same conversation-thread look as before,
/// but every message comes from a fixed House Rent / House Listing preset;
/// there is no free-text input, so users can only pick from the allowed
/// questions. Content switches to Bangla automatically when that's the
/// selected app language.
class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<_SupportMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    final isBangla = context.read<LocaleProvider>().language == AppLanguage.bangla;
    _messages.add(
      _SupportMessage(
        text: isBangla
            ? 'হাই! আমি DwellWise সাপোর্ট বট। নিচের যেকোনো প্রিসেট প্রশ্নে চাপুন উত্তর দেখতে।'
            : 'Hi! I\'m the DwellWise support bot. Tap a preset question below to see the answer.',
        isUser: false,
      ),
    );
  }

  @override
  void dispose() {
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

  void _askPreset(_FaqEntry faq, bool isBangla) {
    setState(() {
      _messages.add(_SupportMessage(text: faq.question(isBangla), isUser: true));
    });
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _messages.add(_SupportMessage(text: faq.answer(isBangla), isUser: false));
      });
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isBangla = context.watch<LocaleProvider>().language == AppLanguage.bangla;

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.t(context, 'menu_help'))),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  isBangla ? 'সচরাচর জিজ্ঞাসিত প্রশ্ন' : 'Frequently Asked Questions',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ),
            for (final category in _faqCategories)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                      child: Text(
                        category.title(isBangla),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: category.entries.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final faq = category.entries[index];
                          return ActionChip(
                            label: Text(faq.question(isBangla)),
                            onPressed: () => _askPreset(faq, isBangla),
                          );
                        },
                      ),
                    ),
                  ],
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
          ],
        ),
      ),
    );
  }
}
