import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_colors.dart';
import '../../providers/property_provider.dart';
import '../../widgets/bottom_navigation.dart';

/// Screen displaying interactive geocoded price pins overlays.
class TenantMapViewScreen extends StatefulWidget {
  const TenantMapViewScreen({Key? key}) : super(key: key);

  @override
  State<TenantMapViewScreen> createState() => _TenantMapViewScreenState();
}

class _TenantMapViewScreenState extends State<TenantMapViewScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final properties = context.watch<PropertyProvider>().properties;

    return Scaffold(
      appBar: AppBar(title: const Text('Dhaka Map View')),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [colors.primaryTint, colors.background],
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.map_outlined, size: 64, color: Color(0xff0F766E)),
                        const SizedBox(height: 16),
                        const Text(
                          'Map preview is disabled',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Configure a Google Maps API key in AndroidManifest.xml to enable the live map view.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Loaded properties: ${properties.length}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => context.go('/listings'),
                            child: const Text('Browse Listings Instead'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              color: colors.surface.withOpacity(0.9),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xff0F766E)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Map view is temporarily unavailable until a Google Maps API key is added.',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 1),
    );
  }
}
