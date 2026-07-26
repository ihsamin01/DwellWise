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
    final id = _propertyIdFrom(uri);
    if (id != null && id.isNotEmpty) {
      AppRoutes.router.go('/property-details/$id');
    }
  }

  /// Extracts the property id from any supported link shape:
  ///  - dwellwise://property/<id>          (custom scheme)
  ///  - https://ihsamin01.github.io/DwellWise/?id=<id>  (verified App Link)
  String? _propertyIdFrom(Uri uri) {
    if (uri.scheme == 'dwellwise') {
      if (uri.host == 'property' && uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.first;
      }
      if (uri.pathSegments.length >= 2 && uri.pathSegments.first == 'property') {
        return uri.pathSegments[1];
      }
      return null;
    }

    if (uri.scheme == 'https' && uri.host == 'ihsamin01.github.io') {
      // https://ihsamin01.github.io/DwellWise/?id=<id>
      final queryId = uri.queryParameters['id'];
      if (queryId != null && queryId.isNotEmpty) {
        return queryId;
      }
      // Fallback: .../DwellWise/property/<id>
      final segs = uri.pathSegments;
      final idx = segs.indexOf('property');
      if (idx != -1 && idx + 1 < segs.length) {
        return segs[idx + 1];
      }
    }
    return null;
  }

  void dispose() {
    _subscription?.cancel();
  }
}
