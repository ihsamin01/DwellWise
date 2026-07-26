import 'dart:async';

import 'package:app_links/app_links.dart';

import '../config/routes.dart';

/// Listens for incoming `dwellwise://property/<id>` deep links (shared via
/// WhatsApp, Messenger, etc.) and routes straight to that property's details
/// screen — both on cold start and while the app is already running.
class DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;

  Future<void> init() async {
    // App opened from a link while it was terminated.
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      _handleUri(initialUri);
    }

    // App already running / in background.
    _subscription = _appLinks.uriLinkStream.listen(
      _handleUri,
      onError: (_) {},
    );
  }

  void _handleUri(Uri uri) {
    if (uri.scheme != 'dwellwise') {
      return;
    }

    // Supports dwellwise://property/<id> (host = property) and
    // dwellwise:///property/<id> (first path segment = property).
    String? id;
    if (uri.host == 'property' && uri.pathSegments.isNotEmpty) {
      id = uri.pathSegments.first;
    } else if (uri.pathSegments.length >= 2 &&
        uri.pathSegments.first == 'property') {
      id = uri.pathSegments[1];
    }

    if (id != null && id.isNotEmpty) {
      AppRoutes.router.go('/property-details/$id');
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
