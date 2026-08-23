import 'package:flutter/material.dart';

/// What a notification is about.
enum NotificationKind {
  message,
  priceDrop,
  match,
  verification,
  update,
  maintenance,
  system;

  static NotificationKind fromName(String? name) {
    return NotificationKind.values.firstWhere(
      (k) => k.name == name,
      orElse: () => NotificationKind.system,
    );
  }

  IconData get icon {
    switch (this) {
      case NotificationKind.message:
        return Icons.chat_bubble_outline;
      case NotificationKind.priceDrop:
        return Icons.trending_down;
      case NotificationKind.match:
        return Icons.home_work_outlined;
      case NotificationKind.verification:
        return Icons.verified_outlined;
      case NotificationKind.update:
        return Icons.system_update_outlined;
      case NotificationKind.maintenance:
        return Icons.build_outlined;
      case NotificationKind.system:
        return Icons.notifications_none;
    }
  }
}

/// A single in-app notification.
class NotificationModel {
  final String id;
  final IconData icon;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.icon,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
  });

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      icon: icon,
      title: title,
      message: message,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}
