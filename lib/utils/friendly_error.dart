import 'dart:async';
import 'dart:io';

/// Turns whatever an auth or network call threw into something worth
/// showing a person.
///
/// Without this the login screen printed the exception as it came —
/// "PlatformException(network_error, com.google.android.gms.common.api
/// .ApiException: 7: , null, null)" — which says nothing to someone whose
/// wifi is simply off.
String friendlyError(Object error) {
  if (_looksOffline(error)) {
    return 'No internet connection. Please check your network and try again.';
  }

  final message = _plainMessage(error);
  return _isUseful(message)
      ? message
      : 'Something went wrong. Please try again.';
}

/// Whether [error] is the network being unavailable rather than a real
/// failure of whatever was being attempted.
bool _looksOffline(Object error) {
  if (error is SocketException || error is TimeoutException) return true;

  final text = error.toString().toLowerCase();
  return const [
    'socketexception',
    'failed host lookup',
    'no address associated',
    'network is unreachable',
    'connection refused',
    'connection closed',
    'connection reset',
    'network_error',
    // Google Play services' NETWORK_ERROR, which arrives only as a number.
    'apiexception: 7',
    'clientexception',
    'timeoutexception',
    'operation timed out',
  ].any(text.contains);
}

/// Whether what is left says anything. A bare "Exception" or "Error" is
/// the wrapper with nothing inside it.
bool _isUseful(String message) {
  if (message.isEmpty) return false;
  return !RegExp(r'^\w*(Exception|Error):?$').hasMatch(message);
}

/// Strips the exception wrapper so a message reads as a sentence.
String _plainMessage(Object error) {
  var text = error.toString().trim();

  for (final prefix in const [
    'Exception:',
    'AuthException:',
    'StateError:',
    'PlatformException:',
  ]) {
    if (text.startsWith(prefix)) {
      text = text.substring(prefix.length).trim();
    }
  }

  // "PlatformException(code, message, details, stacktrace)" — keep the
  // message, drop the rest.
  final wrapped = RegExp(r'^\w*Exception\((?:[^,]*,\s*)?([^,]*)').firstMatch(text);
  if (wrapped != null) {
    final inner = wrapped.group(1)?.trim() ?? '';
    if (inner.isNotEmpty && inner != 'null') text = inner;
  }

  return text;
}
