import 'package:flutter/material.dart';
import '../../widgets/bottom_navigation.dart';

/// Screen listing sent inquiries status checks.
class TenantInquiriesScreen extends StatelessWidget {
  const TenantInquiriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Applications')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInquiryCard(
            title: 'Premium Glass Penthouse',
            area: 'Gulshan 2',
            price: '1,20,000 BDT',
            status: 'Pending Review',
            statusColor: Color(0xff1877F2),
          ),
          const SizedBox(height: 16),
          _buildInquiryCard(
            title: 'Modern Skyline Studio',
            area: 'Banani',
            price: '60,000 BDT',
            status: 'Approved',
            statusColor: const Color(0xff10B981),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 4),
    );
  }

  Widget _buildInquiryCard({
    required String title,
    required String area,
    required String price,
    required String status,
    required Color statusColor,
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
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('$area • Offered: $price', style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 4),
            const Text(
              'No feedback messages from owner yet.',
              style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
