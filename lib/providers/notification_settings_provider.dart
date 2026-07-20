import 'package:flutter/material.dart';

/// Provider handling the tenant's notification preferences.
class NotificationSettingsProvider with ChangeNotifier {
  bool _pushNotifications = true;
  bool _propertyUpdates = true;
  bool _newMessages = true;
  bool _bookingUpdates = true;
  bool _promotionalOffers = false;
  bool _securityAlerts = true;

  bool _doNotDisturb = false;
  TimeOfDay _dndStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _dndEnd = const TimeOfDay(hour: 7, minute: 0);

  bool get pushNotifications => _pushNotifications;
  bool get propertyUpdates => _propertyUpdates;
  bool get newMessages => _newMessages;
  bool get bookingUpdates => _bookingUpdates;
  bool get promotionalOffers => _promotionalOffers;
  bool get securityAlerts => _securityAlerts;

  bool get doNotDisturb => _doNotDisturb;
  TimeOfDay get dndStart => _dndStart;
  TimeOfDay get dndEnd => _dndEnd;

  void setPushNotifications(bool value) {
    _pushNotifications = value;
    notifyListeners();
  }

  void setPropertyUpdates(bool value) {
    _propertyUpdates = value;
    notifyListeners();
  }

  void setNewMessages(bool value) {
    _newMessages = value;
    notifyListeners();
  }

  void setBookingUpdates(bool value) {
    _bookingUpdates = value;
    notifyListeners();
  }

  void setPromotionalOffers(bool value) {
    _promotionalOffers = value;
    notifyListeners();
  }

  void setSecurityAlerts(bool value) {
    _securityAlerts = value;
    notifyListeners();
  }

  void setDoNotDisturb(bool value) {
    _doNotDisturb = value;
    notifyListeners();
  }

  void setDndStart(TimeOfDay time) {
    _dndStart = time;
    notifyListeners();
  }

  void setDndEnd(TimeOfDay time) {
    _dndEnd = time;
    notifyListeners();
  }
}
