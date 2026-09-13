import 'dart:async';

import 'package:flutter/material.dart';

import '../models/property_model.dart';
import '../services/assistant_history_service.dart';
import '../services/assistant_service.dart';
import '../services/supabase_service.dart';
import '../utils/address_area.dart';
import '../utils/language_detect.dart';
import '../utils/property_matcher.dart';

enum AssistantRole { user, assistant }

/// One turn in the assistant conversation.
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

  /// Shown back to the user as "this is what I understood".
  final SearchIntent? requirements;

  final bool isPending;

  bool get isUser => role == AssistantRole.user;
}

/// Conversation state for the AI assistant tab.
class AssistantProvider with ChangeNotifier {
  final AssistantService _service = AssistantService();
  final AssistantHistoryService _history = AssistantHistoryService();
  final SupabaseService _db = SupabaseService();

  final List<AssistantMessage> _messages = [];
  SearchIntent? _intent;
  bool _isBusy = false;

  /// Whether the last message was Bangla, in either script.
  bool isBangla = false;

  /// The conversation being written to, created on the first message.
  String? _conversationId;

  List<AssistantConversation> _recent = const [];

  /// Past conversations, most recently used first.
  List<AssistantConversation> get recent => _recent;

  String? get conversationId => _conversationId;

  List<AssistantMessage> get messages => List.unmodifiable(_messages);
  SearchIntent? get intent => _intent;
  bool get isBusy => _isBusy;

  /// The listings from the most recent answer.
  List<MatchResult> get pinnedMatches {
    for (final message in _messages.reversed) {
      if (message.matches.isNotEmpty) return message.matches;
    }
    return const [];
  }

  /// [profileAddress] is offered as a suggestion when the user has not said.
  Future<void> send(String text, {String? profileAddress}) async {
    final message = text.trim();
    if (message.isEmpty || _isBusy) return;

    // Every message decides its own language.
    isBangla = detectLanguage(message) == 'bn';

    _messages.add(AssistantMessage(
      role: AssistantRole.user,
      text: message,
    ));
    unawaited(_remember(role: 'user', content: message));
    _messages.add(const AssistantMessage(
      role: AssistantRole.assistant,
      text: '',
      isPending: true,
    ));
    _isBusy = true;
    notifyListeners();

    try {
      final homeArea = areaFromAddress(profileAddress);
      final reading = await _service.interpret(
        message,
        previous: _intent,
        homeArea: homeArea,
      );

      if (reading == null) {
        // Reached the service but could not make sense of the reply.
        _replacePending(AssistantMessage(
          role: AssistantRole.assistant,
          text: isBangla
              ? 'ঠিক বুঝতে পারিনি। আরেকবার বলবেন?'
              : 'Sorry, I could not understand that. Could you say it again?',
        ));
        return;
      }

      // A greeting or a question about the app, not a search.
      if (!reading.isSearch) {
        _replacePending(AssistantMessage(
          role: AssistantRole.assistant,
          text: reading.reply!,
        ));
        unawaited(_remember(role: 'assistant', content: reading.reply!));
        return;
      }

      final intent = reading.intent!;
      _intent = intent;

      // Location is the one requirement worth stopping for.
      if (intent.area == null || intent.area!.trim().isEmpty) {
        _replacePending(AssistantMessage(
          role: AssistantRole.assistant,
          text: _askForArea(intent, homeArea ?? profileAddress),
          requirements: intent,
        ));
        return;
      }

      final result = await _service.search(intent);
      final reply = await _service.writeReply(intent: intent, result: result);

      final shown = result.matches.take(AssistantService.displayLimit).toList();
      _replacePending(AssistantMessage(
        role: AssistantRole.assistant,
        text: reply,
        matches: shown,
        cheaperNearby: result.cheaperNearby,
        requirements: intent,
      ));
      unawaited(_remember(
        role: 'assistant',
        content: reply,
        propertyIds: [for (final m in shown) m.property.id],
      ));
    } on AssistantUnavailable {
      // Never reached the service.
      _replacePending(AssistantMessage(
        role: AssistantRole.assistant,
        text: isBangla
            ? 'এই মুহূর্তে সংযোগ পাওয়া যাচ্ছে না। ইন্টারনেট দেখে আবার চেষ্টা করুন।'
            : 'I cannot reach the service right now. Check your connection and try again.',
      ));
    } catch (_) {
      _replacePending(AssistantMessage(
        role: AssistantRole.assistant,
        text: isBangla
            ? 'কিছু একটা সমস্যা হয়েছে। আবার চেষ্টা করুন।'
            : 'Something went wrong. Please try again.',
      ));
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  /// Starts a fresh conversation. The old one stays in the history.
  void reset() {
    _messages.clear();
    _intent = null;
    _conversationId = null;
    notifyListeners();
  }

  /// Drops the conversation and the history list for the account that
  /// just left, so the next one does not open someone else's chats.
  void clearForSignOut() {
    _messages.clear();
    _intent = null;
    _conversationId = null;
    _recent = const [];
    notifyListeners();
  }

  /// Reloads the history list shown in the side panel.
  Future<void> loadRecent() async {
    try {
      _recent = await _history.recent();
      notifyListeners();
    } catch (_) {
      // Leave whatever is already listed.
    }
  }

  /// Reopens a past conversation.
  Future<void> openConversation(String conversationId) async {
    _conversationId = conversationId;
    _messages.clear();
    _isBusy = true;
    notifyListeners();

    try {
      final stored = await _history.messages(conversationId);

      // One query for every listing mentioned across the conversation, so the
      // cards come back with the replies that showed them.
      final ids = <String>{
        for (final m in stored) ...m.propertyIds,
      };
      final properties = <String, PropertyModel>{
        for (final p in await _db.getPropertiesByIds(ids.toList())) p.id: p,
      };

      for (final m in stored) {
        _messages.add(AssistantMessage(
          role: m.isUser ? AssistantRole.user : AssistantRole.assistant,
          text: m.content,
          matches: [
            for (final id in m.propertyIds)
              if (properties[id] != null)
                MatchResult(
                  property: properties[id]!,
                  score: 100,
                  matched: const [],
                  shortfalls: const [],
                ),
          ],
        ));
      }
    } catch (_) {
      _messages.add(const AssistantMessage(
        role: AssistantRole.assistant,
        text: 'Could not load that conversation.',
      ));
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    _recent = [for (final c in _recent) if (c.id != conversationId) c];
    if (_conversationId == conversationId) reset();
    notifyListeners();
    try {
      await _history.delete(conversationId);
    } catch (_) {
      await loadRecent();
    }
  }

  /// Writes a turn to the current conversation, starting one if needed.
  Future<void> _remember({
    required String role,
    required String content,
    List<String> propertyIds = const [],
  }) async {
    try {
      _conversationId ??= await _history.create(content);
      final id = _conversationId;
      if (id == null) return;

      await _history.addMessage(
        conversationId: id,
        role: role,
        content: content,
        propertyIds: propertyIds,
      );
      await loadRecent();
    } catch (_) {
      // History is a convenience; a failure here must not break the reply.
    }
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
