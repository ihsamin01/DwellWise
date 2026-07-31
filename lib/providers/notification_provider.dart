import 'package:flutter/material.dart';
import '../models/notification_model.dart';

/// Provider holding the mock notification inbox and unread count. Frontend
/// only — no backend/API, just local state.
class NotificationProvider with ChangeNotifier {
  final List<NotificationModel> _notifications = [
    NotificationModel(
      id: 'n1',
      icon: Icons.chat_bubble_outline,
      title: 'New message from owner',
      message: 'Rashed Ahmed sent you a message about Bachelor Sublet Room, Mirpur 11.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
      isRead: false,
    ),
    NotificationModel(
      id: 'n2',
      icon: Icons.trending_down,
      title: 'Price reduced',
      message: 'The rent for Family Flat, Mirpur 11 dropped to ৳15,000.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
    ),
    NotificationModel(
      id: 'n3',
      icon: Icons.home_work_outlined,
      title: 'New match found',
      message: 'A new 2-bed apartment in Uttara matches your saved search.',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: false,
    ),
    NotificationModel(
      id: 'n4',
      icon: Icons.verified_outlined,
      title: 'Government ID verified',
      message: 'Your account is now verified with a green badge.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: false,
    ),
    NotificationModel(
      id: 'n5',
      icon: Icons.system_update_outlined,
      title: 'Update available',
      message: 'DwellWise 2.1 is available with faster search and bug fixes.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isRead: false,
    ),
    NotificationModel(
      id: 'n6',
      icon: Icons.build_outlined,
      title: 'Scheduled maintenance',
      message: 'DwellWise will be briefly unavailable Friday, 1:00-2:00 AM for maintenance.',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      isRead: true,
    ),
  ];

  List<NotificationModel> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Marks [id] as read if it isn't already. Tapping an already-read
  /// notification is a deliberate no-op — no state change, no rebuild.
  /// Pushes a new unread notification to the top of the inbox (e.g. when an
  /// account gets verified).
  void addNotification({
    required IconData icon,
    required String title,
    required String message,
  }) {
    _notifications.insert(
      0,
      NotificationModel(
        id: 'n-${DateTime.now().millisecondsSinceEpoch}',
        icon: icon,
        title: title,
        message: message,
        timestamp: DateTime.now(),
        isRead: false,
      ),
    );
    notifyListeners();
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index == -1 || _notifications[index].isRead) return;

    _notifications[index] = _notifications[index].copyWith(isRead: true);
    notifyListeners();
  }
}
