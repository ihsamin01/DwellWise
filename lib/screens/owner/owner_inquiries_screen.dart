import 'package:flutter/material.dart';

/// Screen listing inquiries received from potential tenants.
class OwnerInquiriesScreen extends StatelessWidget {
  const OwnerInquiriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Applications Received')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildApplicationCard(
            context,
            tenantName: 'Samin Azhan',
            propertyTitle: 'Premium Glass Penthouse',
            offeredPrice: '1,20,000 BDT',
            message: 'Hello, is this penthouse available for visit this Friday morning?',
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationCard(
    BuildContext context, {
    required String tenantName,
    required String propertyTitle,
    required String offeredPrice,
    required String message,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tenantName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Text('Pending', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Listing: $propertyTitle',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Text('Offered rent: $offeredPrice'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Text('"$message"', style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Offer rejected.')),
                      );
                    },
                    child: const Text('Reject', style: TextStyle(color: Colors.red)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Offer accepted.')),
                      );
                    },
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
