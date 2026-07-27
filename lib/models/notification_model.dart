import 'package:flutter/material.dart';

/// A single mock in-app notification.
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
