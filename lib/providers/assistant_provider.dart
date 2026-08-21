import 'package:flutter/material.dart';

import '../services/assistant_service.dart';
import '../utils/property_matcher.dart';

enum AssistantRole { user, assistant }

/// One turn in the assistant conversation.
///
/// [matches] is what the UI draws as tappable property cards. It is kept
/// separate from [text] on purpose: the model writes the wording, but the
/// listings come from the database, so it can never link somewhere that does
/// not exist.
class AssistantMessage {
  const AssistantMessage({
    required this.role,
    required this.text,
    this.matches = const [],
    this.cheaperNearby = const [],
    this.requirements,
    this.isPending = false,
  });

  final AssistantRole role;
  final String text;
  final List<MatchResult> matches;
  final List<MatchResult> cheaperNearby;

  /// Shown back to the user as "this is what I understood", so a misread
  /// request is caught before they scroll through the wrong listings.
  final SearchIntent? requirements;

  final bool isPending;

  bool get isUser => role == AssistantRole.user;
}

/// Conversation state for the AI assistant tab.
///
/// The requirements accumulate across turns, so "gas thakle bhalo" after
/// "3 room in ECB" searches for all three rather than starting over.
class AssistantProvider with ChangeNotifier {
  final AssistantService _service = AssistantService();

  final List<AssistantMessage> _messages = [];
  SearchIntent? _intent;
  bool _isBusy = false;

  List<AssistantMessage> get messages => List.unmodifiable(_messages);
  SearchIntent? get intent => _intent;
  bool get isBusy => _isBusy;

  /// The listings from the most recent answer, kept so a follow-up question
  /// ("does the second one have gas?") is answered from the rows themselves.
  List<MatchResult> get pinnedMatches {
    for (final message in _messages.reversed) {
      if (message.matches.isNotEmpty) return message.matches;
    }
    return const [];
  }

  /// [profileAddress] is offered as a suggestion when the user has not said
  /// where they are looking — asked, never assumed, since a profile address
  /// can be stale or simply not where they want to live.
  Future<void> send(String text, {String? profileAddress}) async {
    final message = text.trim();
    if (message.isEmpty || _isBusy) return;

    _messages.add(AssistantMessage(
      role: AssistantRole.user,
      text: message,
    ));
    _messages.add(const AssistantMessage(
      role: AssistantRole.assistant,
      text: '',
      isPending: true,
    ));
    _isBusy = true;
    notifyListeners();

    try {
      final intent = await _service.extractIntent(message, previous: _intent);

      if (intent == null) {
        // Reached the service but could not make sense of the reply — this one
        // really is about the wording.
        _replacePending(AssistantMessage(
          role: AssistantRole.assistant,
          text: (_intent?.isBangla ?? false)
              ? 'ঠিক বুঝতে পারিনি। আরেকবার বলবেন?'
              : 'Sorry, I could not understand that. Could you say it again?',
        ));
        return;
      }

      _intent = intent;

      // Location is the one requirement worth stopping for: without it there
      // is nothing to search. Everything else the scoring handles on its own.
      if (intent.area == null || intent.area!.trim().isEmpty) {
        _replacePending(AssistantMessage(
          role: AssistantRole.assistant,
          text: _askForArea(intent, profileAddress),
          requirements: intent,
        ));
        return;
      }

      final result = await _service.search(intent);
      final reply = await _service.writeReply(intent: intent, result: result);

      _replacePending(AssistantMessage(
        role: AssistantRole.assistant,
        text: reply,
        matches: result.matches.take(AssistantService.displayLimit).toList(),
        cheaperNearby: result.cheaperNearby,
        requirements: intent,
      ));
    } on AssistantUnavailable {
      // Never reached the service: say so, rather than telling the user their
      // request was unclear when it was the connection that failed.
      _replacePending(AssistantMessage(
        role: AssistantRole.assistant,
        text: (_intent?.isBangla ?? false)
            ? 'এই মুহূর্তে সংযোগ পাওয়া যাচ্ছে না। ইন্টারনেট দেখে আবার চেষ্টা করুন।'
            : 'I cannot reach the service right now. Check your connection and try again.',
      ));
    } catch (_) {
      _replacePending(AssistantMessage(
        role: AssistantRole.assistant,
        text: (_intent?.isBangla ?? false)
            ? 'কিছু একটা সমস্যা হয়েছে। আবার চেষ্টা করুন।'
            : 'Something went wrong. Please try again.',
      ));
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  /// Starts over — used by "new chat".
  void reset() {
    _messages.clear();
    _intent = null;
    notifyListeners();
  }

  String _askForArea(SearchIntent intent, String? profileAddress) {
    final hasSuggestion =
        profileAddress != null && profileAddress.trim().isNotEmpty;

    if (intent.isBangla) {
      return hasSuggestion
          ? 'কোন এলাকায় খুঁজব? আপনার প্রোফাইলে "$profileAddress" দেওয়া আছে — সেখানেই খুঁজব?'
          : 'কোন এলাকায় খুঁজব? এলাকার নামটি বলুন।';
    }
    return hasSuggestion
        ? 'Which area should I search? Your profile says "$profileAddress" — shall I look there?'
        : 'Which area should I search? Tell me the area name.';
  }

  void _replacePending(AssistantMessage message) {
    final index = _messages.lastIndexWhere((m) => m.isPending);
    if (index == -1) {
      _messages.add(message);
    } else {
      _messages[index] = message;
    }
    notifyListeners();
  }
}
