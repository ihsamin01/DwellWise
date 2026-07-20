import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/property_card.dart';

/// A property the user has rented through DwellWise.
class _RentedProperty {
  final String title;
  final String type;
  final String location;
  final double price;
  final String priceFor;
  final DateTime rentedOn;
  final String reference;
  final String imageUrl;

  const _RentedProperty({
    required this.title,
    required this.type,
    required this.location,
    required this.price,
    required this.priceFor,
    required this.rentedOn,
    required this.reference,
    required this.imageUrl,
  });
}

/// Rental history: the houses / flats / sublets the user has rented through
/// the app, with the price paid. Dummy data for the demo.
class PurchaseHistoryScreen extends StatelessWidget {
  const PurchaseHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    final rentals = <_RentedProperty>[
      _RentedProperty(
        title: 'Bachelor Sublet Room, Farmgate',
        type: 'Sublet',
        location: 'Indira Road, Farmgate, Dhaka',
        price: 6500,
        priceFor: 'Monthly',
        rentedOn: DateTime.now().subtract(const Duration(days: 5)),
        reference: 'RENT-5521048',
        imageUrl:
            'https://images.unsplash.com/photo-1540518614846-7eded433c457?auto=format&fit=crop&w=600&q=80',
      ),
      _RentedProperty(
        title: 'Family Flat, Mirpur 11',
        type: 'Flat',
        location: 'Road 3, Mirpur 11, Dhaka',
        price: 16000,
        priceFor: 'Monthly',
        rentedOn: DateTime.now().subtract(const Duration(days: 63)),
        reference: 'RENT-5390127',
        imageUrl:
            'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&w=600&q=80',
      ),
    ];

    final total = rentals.fold<double>(0, (sum, r) => sum + r.price);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: const Text('Purchase history')),
      body: rentals.isEmpty
          ? Center(
              child: Text('No rentals yet',
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total rent paid',
                              style: TextStyle(fontSize: 15, color: colors.textSecondary)),
                          const SizedBox(height: 2),
                          Text('${rentals.length} propert${rentals.length == 1 ? 'y' : 'ies'} rented',
                              style: TextStyle(fontSize: 12, color: colors.textSecondary)),
                        ],
                      ),
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
                ...rentals.map((r) => _RentalTile(rental: r, colors: colors)),
              ],
            ),
    );
  }
}

class _RentalTile extends StatelessWidget {
  final _RentedProperty rental;
  final AppColors colors;
  const _RentalTile({required this.rental, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: rental.imageUrl,
                    width: 84,
                    height: 84,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                        width: 84, height: 84, color: colors.placeholder),
                    errorWidget: (_, __, ___) => Container(
                      width: 84,
                      height: 84,
                      color: colors.placeholder,
                      child: Icon(Icons.home_work_outlined, color: colors.textSecondary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              rental.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: colors.textPrimary),
                            ),
                          ),
                          _typePill(rental.type),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 13, color: colors.textSecondary),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              rental.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12.5, color: colors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '৳${formatWithCommas(rental.price)}',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colors.primary),
                          ),
                          Text(' / ${rental.priceFor.toLowerCase()}',
                              style: TextStyle(fontSize: 12, color: colors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle, size: 15, color: Color(0xff10B981)),
                    const SizedBox(width: 5),
                    Text('Rented · ${Formatters.formatDate(rental.rentedOn)}',
                        style: TextStyle(fontSize: 12, color: colors.textSecondary)),
                  ],
                ),
                Text(rental.reference,
                    style: TextStyle(fontSize: 11.5, color: colors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _typePill(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: colors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        type,
        style: TextStyle(
            fontSize: 10.5, fontWeight: FontWeight.w700, color: colors.primary),
      ),
    );
  }
}
