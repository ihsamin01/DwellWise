import 'package:flutter/material.dart';
import '../models/property_model.dart';
import '../services/supabase_service.dart';

/// Provider handling Property listings retrieval, insertion, and detail focus updates.
class PropertyProvider with ChangeNotifier {
  final SupabaseService _dbService = SupabaseService();

  List<PropertyModel> _properties = [];
  PropertyModel? _selectedProperty;
  bool _isLoading = false;
  final Set<String> _savedPropertyIds = {};

  List<PropertyModel> get properties => _properties;
  PropertyModel? get selectedProperty => _selectedProperty;
  bool get isLoading => _isLoading;
  
  List<PropertyModel> get savedProperties =>
      _properties.where((p) => _savedPropertyIds.contains(p.id)).toList();

  /// Loads properties list.
  Future<void> fetchProperties() async {
    _isLoading = true;
    notifyListeners();
    try {
      _properties = await _dbService.getProperties();
      // If list is empty, initialize mock data for presentation reliability
      if (_properties.isEmpty) {
        _loadMockProperties();
      }
    } catch (e) {
      debugPrint('Error listing properties: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Registers a new property listing.
  Future<bool> addProperty(PropertyModel newProperty) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _dbService.createProperty(newProperty);
      _properties.insert(0, newProperty);
      return true;
    } catch (e) {
      debugPrint('Error creating listing: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sets selected property focus.
  void selectProperty(PropertyModel property) {
    _selectedProperty = property;
    notifyListeners();
  }

  /// Toggles favorite status of a property.
  void toggleFavorite(String propertyId) {
    if (_savedPropertyIds.contains(propertyId)) {
      _savedPropertyIds.remove(propertyId);
    } else {
      _savedPropertyIds.add(propertyId);
    }
    notifyListeners();
  }

  /// Checks if a property is favorited.
  bool isSaved(String propertyId) {
    return _savedPropertyIds.contains(propertyId);
  }

  void _loadMockProperties() {
    // Image pool of modest interior/room stock photos (verified reachable).
    const img = 'https://images.unsplash.com/photo-';
    const q = '?auto=format&fit=crop&w=600&q=80';

    _properties = [
      PropertyModel(
        id: 'p12',
        title: 'Bachelor Sublet Room, Mirpur 11',
        description:
            'Single furnished room for a working bachelor. Attached bath, shared kitchen, gas and water bill included. 5 minutes from Mirpur 11 bus stand and metro station. Two months advance required.',
        price: 6500,
        propertyType: 'Sublet',
        area: 'Mirpur 11',
        address: 'Block C, Mirpur 11, Dhaka',
        latitude: 23.8069,
        longitude: 90.3654,
        beds: 1,
        baths: 1,
        sizeSqFt: 180,
        imageUrls: [
          '${img}1540518614846-7eded433c457$q',
          '${img}1505691938895-1758d7feb511$q',
          '${img}1493809842364-78817add7ffb$q',
        ],
        isVerified: false,
        ownerId: 'o8',
        facilities: ['Wifi', 'Gas', 'Security'],
        createdAt: DateTime.now(),
      ),
      PropertyModel(
        id: 'p13',
        title: 'Family Flat, Mirpur 11',
        description:
            'Spacious 2-bed family apartment near Mirpur 11 kacha bazar. Gas line, lift, and 24/7 security guard. Walking distance to schools and Purobi. Service charge 3,000 extra.',
        price: 16000,
        propertyType: 'Apartment',
        area: 'Mirpur 11',
        address: 'Road 3, Mirpur 11, Dhaka',
        latitude: 23.8091,
        longitude: 90.3662,
        beds: 2,
        baths: 2,
        sizeSqFt: 850,
        imageUrls: [
          '${img}1502672260266-1c1ef2d93688$q',
          '${img}1554995207-c18c203602cb$q',
          '${img}1484154218962-a197022b5858$q',
          '${img}1524758631624-e2822e304c36$q',
        ],
        isVerified: true,
        ownerId: 'o9',
        facilities: ['Gas', 'Lift', 'Security', 'Parking'],
        createdAt: DateTime.now(),
      ),
      PropertyModel(
        id: 'p14',
        title: '2 Bed Flat, ECB Chattar',
        description:
            'Well-ventilated 2-bedroom flat in Matikata, ECB Chattar. Close to Dhaka Cantonment, good for small families. Gas line and generator backup available.',
        price: 15000,
        propertyType: 'Apartment',
        area: 'ECB Chattar',
        address: 'Matikata, ECB Chattar, Dhaka',
        latitude: 23.8195,
        longitude: 90.3895,
        beds: 2,
        baths: 2,
        sizeSqFt: 800,
        imageUrls: [
          '${img}1600607687939-ce8a6c25118c$q',
          '${img}1502005229762-cf1b2da7c5d6$q',
          '${img}1484154218962-a197022b5858$q',
        ],
        isVerified: true,
        ownerId: 'o10',
        facilities: ['Gas', 'Backup', 'Security'],
        createdAt: DateTime.now(),
      ),
      PropertyModel(
        id: 'p6',
        title: 'Mirpur Heights Family Flat',
        description:
            'Affordable and spacious apartment near Mirpur 10 metro rail station. Safe, family-friendly with security guards and elevator. Gas line included.',
        price: 26000,
        propertyType: 'Apartment',
        area: 'Mirpur 10',
        address: 'Block A, Mirpur 10, Dhaka',
        latitude: 23.8069,
        longitude: 90.3686,
        beds: 3,
        baths: 2,
        sizeSqFt: 1350,
        imageUrls: [
          '${img}1502672260266-1c1ef2d93688$q',
          '${img}1524758631624-e2822e304c36$q',
          '${img}1554995207-c18c203602cb$q',
        ],
        isVerified: true,
        ownerId: 'o5',
        facilities: ['Gas', 'Parking', 'Lift', 'Backup'],
        createdAt: DateTime.now(),
      ),
      PropertyModel(
        id: 'p15',
        title: 'Student Sublet, Uttara Sector 10',
        description:
            'Single room sublet for students in Uttara Sector 10. Furnished with bed, study desk and wifi. Shared kitchen and bathroom with two others. Girls preferred.',
        price: 8000,
        propertyType: 'Sublet',
        area: 'Uttara Sector 10',
        address: 'Road 12, Sector 10, Uttara, Dhaka',
        latitude: 23.8697,
        longitude: 90.3760,
        beds: 1,
        baths: 1,
        sizeSqFt: 200,
        imageUrls: [
          '${img}1505691938895-1758d7feb511$q',
          '${img}1540518614846-7eded433c457$q',
          '${img}1493809842364-78817add7ffb$q',
        ],
        isVerified: false,
        ownerId: 'o11',
        facilities: ['Wifi', 'Gas'],
        createdAt: DateTime.now(),
      ),
      PropertyModel(
        id: 'p16',
        title: 'Family Apartment, Mohammadpur',
        description:
            'Comfortable 2-bed apartment in Mohammadpur near Krishi Market. Gas line, lift, and reserved car parking. Suitable for family or small office. Two months advance.',
        price: 18000,
        propertyType: 'Apartment',
        area: 'Mohammadpur',
        address: 'Nurjahan Road, Mohammadpur, Dhaka',
        latitude: 23.7601,
        longitude: 90.3596,
        beds: 2,
        baths: 2,
        sizeSqFt: 900,
        imageUrls: [
          '${img}1560448204-e02f11c3d0e2$q',
          '${img}1502005229762-cf1b2da7c5d6$q',
          '${img}1554995207-c18c203602cb$q',
          '${img}1484154218962-a197022b5858$q',
        ],
        isVerified: true,
        ownerId: 'o12',
        facilities: ['Gas', 'Lift', 'Parking', 'Security'],
        createdAt: DateTime.now(),
      ),
      PropertyModel(
        id: 'p17',
        title: '2 Bed Flat, Rampura',
        description:
            'Bright 2-bedroom flat in West Rampura, close to DIT road. Gas, water and generator backup. Easy rickshaw access to Banasree and Malibagh.',
        price: 17000,
        propertyType: 'Apartment',
        area: 'Rampura',
        address: 'West Rampura, Dhaka',
        latitude: 23.7605,
        longitude: 90.4188,
        beds: 2,
        baths: 2,
        sizeSqFt: 780,
        imageUrls: [
          '${img}1502005229762-cf1b2da7c5d6$q',
          '${img}1524758631624-e2822e304c36$q',
          '${img}1560448204-e02f11c3d0e2$q',
        ],
        isVerified: false,
        ownerId: 'o13',
        facilities: ['Gas', 'Backup', 'Security'],
        createdAt: DateTime.now(),
      ),
      PropertyModel(
        id: 'p7',
        title: 'Uttara Sector 4 Cosy Nest',
        description:
            'Beautifully designed home in Uttara, ideal for student roommates or small families. Safe parking and internet included. Gas line available.',
        price: 21000,
        propertyType: 'Apartment',
        area: 'Sector 4',
        address: 'Road 3, Sector 4, Uttara, Dhaka',
        latitude: 23.8722,
        longitude: 90.3842,
        beds: 2,
        baths: 2,
        sizeSqFt: 1000,
        imageUrls: [
          '${img}1600607687939-ce8a6c25118c$q',
          '${img}1554995207-c18c203602cb$q',
          '${img}1502005229762-cf1b2da7c5d6$q',
        ],
        isVerified: false,
        ownerId: 'o6',
        facilities: ['Wifi', 'Gas', 'Backup', 'Parking'],
        createdAt: DateTime.now(),
      ),
      PropertyModel(
        id: 'p18',
        title: 'Bachelor Mess Seat, Farmgate',
        description:
            'Seat rent in a clean bachelor mess at Farmgate. Includes bed, almirah, wifi and khala for cooking. Near Tejgaon college and offices. All utility bills included.',
        price: 4500,
        propertyType: 'Seat Rent',
        area: 'Farmgate',
        address: 'Indira Road, Farmgate, Dhaka',
        latitude: 23.7583,
        longitude: 90.3897,
        beds: 1,
        baths: 1,
        sizeSqFt: 120,
        imageUrls: [
          '${img}1493809842364-78817add7ffb$q',
          '${img}1540518614846-7eded433c457$q',
          '${img}1505691938895-1758d7feb511$q',
        ],
        isVerified: false,
        ownerId: 'o14',
        facilities: ['Wifi', 'Gas'],
        createdAt: DateTime.now(),
      ),
      PropertyModel(
        id: 'p19',
        title: 'Small Family Flat, Kazipara',
        description:
            'Affordable 2-bed flat in Kazipara, near Metro Rail station. Gas line and lift available. Good for small families on a budget. One month advance.',
        price: 13000,
        propertyType: 'Apartment',
        area: 'Kazipara',
        address: 'Kazipara, Mirpur, Dhaka',
        latitude: 23.7970,
        longitude: 90.3695,
        beds: 2,
        baths: 1,
        sizeSqFt: 720,
        imageUrls: [
          '${img}1484154218962-a197022b5858$q',
          '${img}1524758631624-e2822e304c36$q',
          '${img}1502672260266-1c1ef2d93688$q',
        ],
        isVerified: true,
        ownerId: 'o15',
        facilities: ['Gas', 'Lift', 'Security'],
        createdAt: DateTime.now(),
      ),
      PropertyModel(
        id: 'p20',
        title: '3 Bed Family Flat, Khilgaon',
        description:
            'Roomy 3-bedroom apartment in Khilgaon Taltola. Gas, lift, parking and generator backup. Close to Khilgaon flyover, schools and bazar.',
        price: 22000,
        propertyType: 'Apartment',
        area: 'Khilgaon',
        address: 'Taltola, Khilgaon, Dhaka',
        latitude: 23.7509,
        longitude: 90.4258,
        beds: 3,
        baths: 2,
        sizeSqFt: 1050,
        imageUrls: [
          '${img}1560448204-e02f11c3d0e2$q',
          '${img}1554995207-c18c203602cb$q',
          '${img}1502005229762-cf1b2da7c5d6$q',
          '${img}1484154218962-a197022b5858$q',
        ],
        isVerified: true,
        ownerId: 'o16',
        facilities: ['Gas', 'Lift', 'Parking', 'Backup'],
        createdAt: DateTime.now(),
      ),
      PropertyModel(
        id: 'p21',
        title: 'Sublet Room, Badda',
        description:
            'Furnished single room with attached bath for sublet in Middle Badda. Wifi and gas included. Suitable for job holders. Near US Embassy road and Gulshan link.',
        price: 9000,
        propertyType: 'Sublet',
        area: 'Badda',
        address: 'Middle Badda, Dhaka',
        latitude: 23.7806,
        longitude: 90.4265,
        beds: 1,
        baths: 1,
        sizeSqFt: 250,
        imageUrls: [
          '${img}1540518614846-7eded433c457$q',
          '${img}1493809842364-78817add7ffb$q',
          '${img}1505691938895-1758d7feb511$q',
        ],
        isVerified: false,
        ownerId: 'o17',
        facilities: ['Wifi', 'Gas', 'Security'],
        createdAt: DateTime.now(),
      ),
      PropertyModel(
        id: 'p11',
        title: 'Gazipur Executive Flat',
        description:
            'Executive family accommodation in Gazipur Sadar. Large living room, secure environment, and direct road connectivity. Gas line included.',
        price: 15000,
        propertyType: 'Apartment',
        area: 'Gazipur Sadar',
        address: 'Sadar Road, Gazipur',
        latitude: 23.9995,
        longitude: 90.4201,
        beds: 3,
        baths: 2,
        sizeSqFt: 1200,
        imageUrls: [
          '${img}1502672260266-1c1ef2d93688$q',
          '${img}1524758631624-e2822e304c36$q',
          '${img}1560448204-e02f11c3d0e2$q',
        ],
        isVerified: false,
        ownerId: 'o7',
        facilities: ['Gas', 'Parking', 'Backup'],
        createdAt: DateTime.now(),
      ),
      PropertyModel(
        id: 'p10',
        title: 'Bashundhara Park View Residence',
        description:
            'Overlooking the central park of Bashundhara. Bright north-facing balconies, separate drawing-dining and kitchen setup. Gas, lift and backup line.',
        price: 33000,
        propertyType: 'Apartment',
        area: 'Bashundhara R/A',
        address: 'Block D, Bashundhara R/A, Dhaka',
        latitude: 23.8285,
        longitude: 90.4321,
        beds: 3,
        baths: 3,
        sizeSqFt: 1550,
        imageUrls: [
          '${img}1522708323590-d24dbb6b0267$q',
          '${img}1600585154340-be6161a56a0c$q',
          '${img}1600566753376-12c8ab7fb75b$q',
        ],
        isVerified: true,
        ownerId: 'o3',
        facilities: ['Gas', 'Parking', 'Lift', 'Backup', 'Wifi'],
        createdAt: DateTime.now(),
      ),
      PropertyModel(
        id: 'p3',
        title: 'Serene Sky Terrace',
        description:
            'High-ceiling terrace flat in Bashundhara R/A with open skylight, ambient lighting, and lake proximity. Modern finish with gas, lift and rooftop access.',
        price: 38000,
        propertyType: 'Apartment',
        area: 'Bashundhara R/A',
        address: 'Block C, Bashundhara R/A, Dhaka',
        latitude: 23.8223,
        longitude: 90.4272,
        beds: 3,
        baths: 2,
        sizeSqFt: 1850,
        imageUrls: [
          '${img}1600607687939-ce8a6c25118c$q',
          '${img}1600566753376-12c8ab7fb75b$q',
          '${img}1512917774080-9991f1c4c750$q',
        ],
        isVerified: true,
        ownerId: 'o3',
        facilities: ['Gas', 'Parking', 'Lift', 'Backup', 'Wifi'],
        createdAt: DateTime.now(),
      ),
      PropertyModel(
        id: 'p5',
        title: 'Gulshan 1 Smart Studio',
        description:
            'Compact studio in Gulshan 1 with keyless entry, smart TV, AC, and high-speed fiber internet. Ideal for a single professional. Lift and backup available.',
        price: 40000,
        propertyType: 'Studio',
        area: 'Gulshan 1',
        address: 'Gulshan Avenue, Gulshan 1, Dhaka',
        latitude: 23.7753,
        longitude: 90.4125,
        beds: 1,
        baths: 1,
        sizeSqFt: 800,
        imageUrls: [
          '${img}1522708323590-d24dbb6b0267$q',
          '${img}1554995207-c18c203602cb$q',
          '${img}1502005229762-cf1b2da7c5d6$q',
        ],
        isVerified: true,
        ownerId: 'o1',
        facilities: ['Wifi', 'Lift', 'Backup', 'Security'],
        createdAt: DateTime.now(),
      ),
    ];
  }
}
