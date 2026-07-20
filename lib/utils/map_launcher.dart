import 'package:url_launcher/url_launcher.dart';

/// Opens Google Maps at an exact address or coordinate — no Maps API key
/// required. Used by the "Mark in maps" / "Open in Google Maps" actions so a
/// typed address like "House 234, Road 6, Mirpur DOHS" jumps straight to the
/// right spot instead of the user scrolling around the map.
class MapLauncher {
  MapLauncher._();

  /// Opens the given free-text [address] in the Google Maps app/website,
  /// centred on the best match. Returns false if no handler could be launched.
  static Future<bool> openAddress(String address) {
    final query = Uri.encodeComponent(address.trim());
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );
    return _launch(uri);
  }

  /// Opens Google Maps centred on a precise latitude/longitude.
  static Future<bool> openCoordinates(double lat, double lng, {String? label}) {
    final query = label != null
        ? '${Uri.encodeComponent(label)}@$lat,$lng'
        : '$lat,$lng';
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng&query_place_id=$query',
    );
    return _launch(uri);
  }

  static Future<bool> _launch(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
