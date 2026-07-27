import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../providers/notification_provider.dart';

/// Mock notification inbox. Tapping an unread notification marks it read
/// in place — no detail page, dialog, or navigation. Tapping an already-read
/// notification does nothing.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  String _formatTimestamp(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final notifications = context.watch<NotificationProvider>().notifications;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: const Text('Notifications')),
      body: notifications.isEmpty
          ? Center(
              child: Text(
                'No notifications yet',
                style: TextStyle(color: colors.textSecondary),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: colors.border),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return InkWell(
                  onTap: notification.isRead
                      ? null
                      : () => context.read<NotificationProvider>().markAsRead(notification.id),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: colors.primaryTint,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(notification.icon, color: colors.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification.title,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                                  color: colors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notification.message,
                                style: TextStyle(fontSize: 13, color: colors.textSecondary, height: 1.4),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _formatTimestamp(notification.timestamp),
                                style: TextStyle(fontSize: 11, color: colors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        if (!notification.isRead) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 9,
                            height: 9,
                            margin: const EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(
                              color: colors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
