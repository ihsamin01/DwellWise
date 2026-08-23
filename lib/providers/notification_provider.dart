import 'package:flutter/material.dart';

import '../models/notification_model.dart';
import '../services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider holding the notification inbox and unread count.
class NotificationProvider with ChangeNotifier {
  NotificationProvider() {
    _channel = _service.subscribe(_onInserted);
    refresh();
  }

  final NotificationService _service = NotificationService();
  final List<NotificationModel> _notifications = [];

  RealtimeChannel? _channel;
  bool _isLoading = false;

  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);

  bool get isLoading => _isLoading;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  void dispose() {
    final channel = _channel;
    if (channel != null) _service.unsubscribe(channel);
    super.dispose();
  }

  Future<void> refresh() async {
    if (_service.currentUserId == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final fetched = await _service.fetch();
      _notifications
        ..clear()
        ..addAll(fetched);
    } catch (_) {
      // Offline.
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Raises a notification for the signed-in user (e.g.
  Future<void> addNotification({
    required NotificationKind kind,
    required String title,
    required String message,
  }) async {
    final optimistic = NotificationModel(
      id: 'pending-${DateTime.now().microsecondsSinceEpoch}',
      icon: kind.icon,
      title: title,
      message: message,
      timestamp: DateTime.now(),
      isRead: false,
    );
    _notifications.insert(0, optimistic);
    notifyListeners();

    try {
      final saved = await _service.add(
        kind: kind,
        title: title,
        message: message,
      );
      final index = _notifications.indexWhere((n) => n.id == optimistic.id);
      if (index == -1) return;
      if (saved == null) {
        _notifications.removeAt(index);
      } else {
        _notifications[index] = saved;
      }
      notifyListeners();
    } catch (_) {
      _notifications.removeWhere((n) => n.id == optimistic.id);
      notifyListeners();
    }
  }

  /// Marks [id] as read if it isn't already.
  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index == -1 || _notifications[index].isRead) return;

    _notifications[index] = _notifications[index].copyWith(isRead: true);
    notifyListeners();

    try {
      await _service.markRead(id);
    } catch (_) {
      // The badge comes back on the next refresh if this did not land.
    }
  }

  /// Marks every notification as read (e.g.
  Future<void> markAllAsRead() async {
    if (unreadCount == 0) return;

    for (var i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    notifyListeners();

    try {
      await _service.markAllRead();
    } catch (_) {
      // Same as above.
    }
  }

  void _onInserted(NotificationModel notification) {
    if (_notifications.any((n) => n.id == notification.id)) return;
    _notifications.insert(0, notification);
    notifyListeners();
  }
}
