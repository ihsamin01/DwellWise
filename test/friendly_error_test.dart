import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:dwell_wise/utils/friendly_error.dart';

const _offline =
    'No internet connection. Please check your network and try again.';

void main() {
  test('the wifi being off reads as the wifi being off', () {
    // Exactly what Google Play services threw on the login screen.
    expect(
      friendlyError(
        'PlatformException(network_error, com.google.android.gms.common.api'
        '.ApiException: 7: , null, null)',
      ),
      _offline,
    );

    expect(friendlyError(const SocketException('Failed host lookup')), _offline);
    expect(friendlyError(TimeoutException('x')), _offline);
    expect(
      friendlyError(Exception('ClientException with SocketException')),
      _offline,
    );
  });

  test('a real failure keeps saying what it was', () {
    expect(
      friendlyError(Exception('Invalid login credentials')),
      'Invalid login credentials',
    );
  });

  test('an empty or unreadable error still says something', () {
    expect(friendlyError(Exception('')), 'Something went wrong. Please try again.');
  });
}
