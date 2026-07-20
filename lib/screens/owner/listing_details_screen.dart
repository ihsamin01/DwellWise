import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/property_provider.dart';
import '../../widgets/verified_badge.dart';

/// Owner-facing listing detail panel displaying verification indicators and statistics.
class OwnerListingDetailsScreen extends StatelessWidget {
  final String propertyId;

  const OwnerListingDetailsScreen({
    Key? key,
    required this.propertyId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final propertyProvider = context.watch<PropertyProvider>();
    final property = propertyProvider.selectedProperty;

    if (property == null || property.id != propertyId) {
      return Scaffold(
        appBar: AppBar(title: const Text('Listing Details')),
        body: const Center(child: Text('Loading details...')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(property.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'STATUS: ${property.isVerified ? "VERIFIED" : "PENDING AUDIT"}',
                  style: TextStyle(
                    color: property.isVerified ? const Color(0xff10B981) : Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (property.isVerified) const VerifiedBadge(),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Views This Week',
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 8),
                    const Text('148', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xff0F766E))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Listing Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Rent: ৳${property.price.toInt()} / month'),
            const SizedBox(height: 8),
            Text('Address: ${property.address}'),
            const SizedBox(height: 8),
            Text('Description: ${property.description}'),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Verification check initiated.')),
                );
              },
              child: const Text('Request Verification Audit'),
            ),
          ],
        ),
      ),
    );
  }
}
