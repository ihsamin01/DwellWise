import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../utils/formatters.dart';

/// A simple record of the user's paid transactions in DwellWise.
class _Purchase {
  final String title;
  final String reference;
  final double amount;
  final DateTime date;

  const _Purchase({
    required this.title,
    required this.reference,
    required this.amount,
    required this.date,
  });
}

/// Read-only list of the user's past purchases (dummy data for the demo).
class PurchaseHistoryScreen extends StatelessWidget {
  const PurchaseHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final purchases = <_Purchase>[
      _Purchase(
        title: 'Account verification fee',
        reference: 'TXN-8842013',
        amount: 500,
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
      _Purchase(
        title: 'Featured listing boost — Mirpur DOHS',
        reference: 'TXN-8790451',
        amount: 300,
        date: DateTime.now().subtract(const Duration(days: 11)),
      ),
      _Purchase(
        title: 'Featured listing boost — Uttara Sector 4',
        reference: 'TXN-8611002',
        amount: 300,
        date: DateTime.now().subtract(const Duration(days: 26)),
      ),
    ];

    final total = purchases.fold<double>(0, (sum, p) => sum + p.amount);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: const Text('Purchase history')),
      body: purchases.isEmpty
          ? Center(
              child: Text('No purchases yet',
                  style: TextStyle(color: colors.textSecondary)),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total spent',
                          style: TextStyle(fontSize: 15, color: colors.textSecondary)),
                      Text(
                        Formatters.formatCurrency(total),
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: colors.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ...purchases.map((p) => _PurchaseTile(purchase: p, colors: colors)),
              ],
            ),
    );
  }
}

class _PurchaseTile extends StatelessWidget {
  final _Purchase purchase;
  final AppColors colors;
  const _PurchaseTile({required this.purchase, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border.withOpacity(0.6)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xff10B981).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.check_circle_outline, color: Color(0xff10B981)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(purchase.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary)),
                const SizedBox(height: 3),
                Text('${purchase.reference} · ${Formatters.formatDate(purchase.date)}',
                    style: TextStyle(fontSize: 12, color: colors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text('৳${purchase.amount.toStringAsFixed(0)}',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary)),
        ],
      ),
    );
  }
}
