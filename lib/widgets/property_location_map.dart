import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../utils/map_launcher.dart';

/// A live map preview (OpenStreetMap tiles — no API key / billing needed) that
/// centres on a property's [latitude]/[longitude] with a pin. Tapping it opens
/// the exact spot in the Google Maps app.
class PropertyLocationMap extends StatelessWidget {
  const PropertyLocationMap({
    super.key,
    required this.latitude,
    required this.longitude,
    this.address,
    this.label,
    this.height = 200,
    this.pinColor = const Color(0xff1877F2),
    this.borderRadius = 8,
  });

  final double latitude;
  final double longitude;
  final String? address;
  final String? label;
  final double height;
  final Color pinColor;
  final double borderRadius;

  Future<void> _openExternal() async {
    // Prefer exact coordinates so the opened map matches the pin; fall back to
    // the typed address if coordinates are missing.
    if (latitude != 0 || longitude != 0) {
      await MapLauncher.openCoordinates(latitude, longitude, label: label);
    } else if (address != null && address!.trim().isNotEmpty) {
      await MapLauncher.openAddress(address!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final center = LatLng(latitude, longitude);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: center,
                initialZoom: 15,
                // Static preview — the whole card opens Google Maps on tap, so
                // in-map gestures are disabled to avoid fighting page scroll.
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.dwell_wise',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: center,
                      width: 44,
                      height: 44,
                      alignment: Alignment.topCenter,
                      child: Icon(Icons.location_pin, color: pinColor, size: 44),
                    ),
                  ],
                ),
              ],
            ),
            // Tap-to-open overlay + a small "tap to open" hint chip.
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(onTap: _openExternal),
              ),
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.map_outlined, size: 14, color: pinColor),
                    const SizedBox(width: 4),
                    Text(
                      'Open in Maps',
                      style: TextStyle(
                        color: pinColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
