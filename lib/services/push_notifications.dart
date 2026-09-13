import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// System notifications for messages that arrive while the app is not the
/// thing the user is looking at.
///
/// These are posted by the app itself, off the realtime subscription, so
/// they arrive whenever the app is running — in front, or in the
/// background. Once Android has stopped the process there is nothing left
/// to post them; that needs a push service delivering from a server.
class PushNotifications {
  PushNotifications._();

  static final PushNotifications instance = PushNotifications._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _ready = false;

  /// Android groups notifications by channel, and the channel's importance
  /// is what decides whether one appears as a banner at the top.
  static const AndroidNotificationDetails _messageChannel =
      AndroidNotificationDetails(
    'messages',
    'Messages',
    channelDescription: 'New messages from people you are talking to',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'New message',
  );

  Future<void> init() async {
    if (_ready) return;
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
      );

      // Android 13 onwards will not show anything until the user agrees.
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      _ready = true;
    } catch (e) {
      debugPrint('Could not set up notifications: $e');
    }
  }

  /// Shows [body] under [title], the way any messaging app would.
  ///
  /// [id] keeps one conversation to a single notification instead of
  /// stacking one per message.
  Future<void> showMessage({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_ready) await init();
    if (!_ready) return;
    try {
      await _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails:
            const NotificationDetails(android: _messageChannel),
      );
    } catch (e) {
      debugPrint('Could not show notification: $e');
    }
  }
}
