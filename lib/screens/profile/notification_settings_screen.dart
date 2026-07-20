import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/notification_settings_provider.dart';

/// Toggle-based notification preferences plus a Do Not Disturb window.
class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  Future<void> _pickTime(BuildContext context, TimeOfDay initial, ValueChanged<TimeOfDay> onPicked) async {
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<NotificationSettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_active_outlined),
                  title: const Text('Push Notifications'),
                  value: settings.pushNotifications,
                  onChanged: settings.setPushNotifications,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.home_work_outlined),
                  title: const Text('Property Updates'),
                  value: settings.propertyUpdates,
                  onChanged: settings.setPropertyUpdates,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.chat_bubble_outline),
                  title: const Text('New Messages'),
                  value: settings.newMessages,
                  onChanged: settings.setNewMessages,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.event_available_outlined),
                  title: const Text('Booking Updates'),
                  value: settings.bookingUpdates,
                  onChanged: settings.setBookingUpdates,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.local_offer_outlined),
                  title: const Text('Promotional Offers'),
                  value: settings.promotionalOffers,
                  onChanged: settings.setPromotionalOffers,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.security_outlined),
                  title: const Text('Security Alerts'),
                  value: settings.securityAlerts,
                  onChanged: settings.setSecurityAlerts,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Do Not Disturb', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.do_not_disturb_on_outlined),
                  title: const Text('Enable Do Not Disturb'),
                  value: settings.doNotDisturb,
                  onChanged: settings.setDoNotDisturb,
                ),
                if (settings.doNotDisturb) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.bedtime_outlined),
                    title: const Text('Start Time'),
                    trailing: Text(
                      settings.dndStart.format(context),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () => _pickTime(context, settings.dndStart, settings.setDndStart),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.wb_sunny_outlined),
                    title: const Text('End Time'),
                    trailing: Text(
                      settings.dndEnd.format(context),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () => _pickTime(context, settings.dndEnd, settings.setDndEnd),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
