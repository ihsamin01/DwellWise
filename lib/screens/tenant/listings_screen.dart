import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/property_provider.dart';
import '../../widgets/property_card.dart';
import '../../widgets/bottom_navigation.dart';

/// Screen listing all available rentals.
class TenantListingsScreen extends StatelessWidget {
  const TenantListingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final propertyProvider = context.watch<PropertyProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('All Rental Listings')),
      body: propertyProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: propertyProvider.properties.length,
              itemBuilder: (context, index) {
                final property = propertyProvider.properties[index];
                return PropertyCard(
                  property: property,
                  onTap: () {
                    propertyProvider.selectProperty(property);
                    context.push('/property-details/${property.id}');
                  },
                );
              },
            ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 3),
    );
  }
}
