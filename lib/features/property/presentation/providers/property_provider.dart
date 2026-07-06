import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/property_model.dart';

// StateNotifier to manage properties list
class PropertyNotifier extends StateNotifier<List<Property>> {
  PropertyNotifier() : super(_initialProperties);

  void addProperty(Property property) {
    state = [property, ...state];
  }

  static final List<Property> _initialProperties = [
    Property(
      id: 'p1',
      title: 'Premium Glass Penthouse',
      area: 'Gulshan 2, Dhaka',
      price: 125000,
      rating: 4.9,
      beds: 3,
      baths: 4,
      sizeSqFt: 3200,
      imageUrl: 'vector_g2',
      isVerified: true,
      ownerName: 'Zeeshan Rahman',
      ownerPhone: '+880 1711-223344',
      ownerImage: 'ZR',
      description: 'Stunning premium penthouse located in the heart of Gulshan 2. Experience glassmorphic architecture with full lake view, smart automation, private elevator access, and a spacious bento-styled terrace. Equipped with 24/7 security standby generator and dual parking.',
      facilities: ['Wifi', 'Parking', 'Lift', 'Backup', 'Gym', 'Pool'],
      latitude: 23.7925,
      longitude: 90.4078,
    ),
    Property(
      id: 'p2',
      title: 'Modern Skyline Studio',
      area: 'Banani, Dhaka',
      price: 62000,
      rating: 4.8,
      beds: 1,
      baths: 1,
      sizeSqFt: 850,
      imageUrl: 'vector_b1',
      isVerified: true,
      ownerName: 'Nadia Chowdhury',
      ownerPhone: '+880 1819-556677',
      ownerImage: 'NC',
      description: 'Fully furnished executive studio apartment in Banani. High-speed fiber internet, card access lobby, modern kitchen fixtures, security guards, and walking distance to prime commercial streets.',
      facilities: ['Wifi', 'Parking', 'Lift', 'Backup'],
      latitude: 23.7937,
      longitude: 90.4033,
    ),
    Property(
      id: 'p3',
      title: 'Spacious Family Duplex',
      area: 'Dhanmondi, Dhaka',
      price: 85000,
      rating: 4.7,
      beds: 4,
      baths: 4,
      sizeSqFt: 2400,
      imageUrl: 'vector_d1',
      isVerified: true,
      ownerName: 'Dr. Tariq Anam',
      ownerPhone: '+880 1515-889900',
      ownerImage: 'TA',
      description: 'Tranquil family duplex overlooking Dhanmondi Lake. Features classic red brick elements combined with contemporary interior layouts. Complete backup generator, lift, and double car porch.',
      facilities: ['Parking', 'Lift', 'Backup', 'Garden'],
      latitude: 23.7461,
      longitude: 90.3742,
    ),
    Property(
      id: 'p4',
      title: 'Cozy Budget Studio',
      area: 'Uttara Sector 11, Dhaka',
      price: 28000,
      rating: 4.5,
      beds: 1,
      baths: 1,
      sizeSqFt: 600,
      imageUrl: 'vector_u1',
      isVerified: false,
      ownerName: 'Tanveer Ahmed',
      ownerPhone: '+880 1911-334455',
      ownerImage: 'TA',
      description: 'Affordable, compact studio for students or young professionals in Uttara. Quiet neighborhood, easy transit access to the metro rail station, individual utility meters, and rooftop accessibility.',
      facilities: ['Wifi', 'Backup'],
      latitude: 23.8722,
      longitude: 90.3842,
    ),
    Property(
      id: 'p5',
      title: 'Luxury Lakeside Suite',
      area: 'Baridhara J Block, Dhaka',
      price: 155000,
      rating: 5.0,
      beds: 3,
      baths: 3,
      sizeSqFt: 2800,
      imageUrl: 'vector_bd1',
      isVerified: true,
      ownerName: 'Zeeshan Rahman',
      ownerPhone: '+880 1711-223344',
      ownerImage: 'ZR',
      description: 'Exclusive lakeside apartment in diplomatic Baridhara zone. Sophisticated visual structure, bulletproof windows, high-security screening, indoor garden workspace, and central HVAC heating/cooling.',
      facilities: ['Wifi', 'Parking', 'Lift', 'Backup', 'Gym', 'Security'],
      latitude: 23.7981,
      longitude: 90.4208,
    ),
  ];
}

// Global provider for properties
final propertiesProvider = StateNotifierProvider<PropertyNotifier, List<Property>>((ref) {
  return PropertyNotifier();
});

// Provider for tracking selected property (for details transition)
final selectedPropertyProvider = StateProvider<Property?>((ref) => null);

// Provider for seeker/owner perspective toggle (true = Seeker, false = Owner)
final perspectiveProvider = StateNotifierProvider<PerspectiveNotifier, bool>((ref) {
  return PerspectiveNotifier();
});

class PerspectiveNotifier extends StateNotifier<bool> {
  PerspectiveNotifier() : super(true);

  void toggle() {
    state = !state;
  }

  void setPerspective(bool isSeeker) {
    state = isSeeker;
  }
}
