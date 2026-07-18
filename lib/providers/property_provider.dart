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
    _properties = [
      PropertyModel(
        id: 'p1',
        title: 'Gulshan 2',
        description: 'Premium lakeside residence in Gulshan 2. Stunning skyline view, luxury fittings, high security and full backup generators.',
        price: 120000,
        area: 'Gulshan 2',
        address: 'Road 88, Gulshan 2, Dhaka',
        latitude: 23.7925,
        longitude: 90.4078,
        beds: 3,
        baths: 3,
        sizeSqFt: 2200,
        imageUrls: ['https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=600&q=80'],
        isVerified: true,
        ownerId: 'o1',
        facilities: ['Wifi', 'Parking', 'Lift', 'Backup'],
        createdAt: DateTime.now(),
      ),
      PropertyModel(
        id: 'p2',
        title: 'Banani, Block H',
        description: 'Exquisite cozy living space in Banani Block H. Semi-furnished with air conditioning, internet access and dynamic security systems.',
        price: 45000,
        area: 'Banani, Block H',
        address: 'Road 11, Banani, Dhaka',
        latitude: 23.7937,
        longitude: 90.4033,
        beds: 2,
        baths: 2,
        sizeSqFt: 1100,
        imageUrls: ['https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&w=600&q=80'],
        isVerified: false,
        ownerId: 'o2',
        facilities: ['Wifi', 'Parking', 'Lift'],
        createdAt: DateTime.now(),
      ),
      PropertyModel(
        id: 'p3',
        title: 'Serene Sky Terrace',
        description: 'Double height high-ceiling terrace loft in Bashundhara. Features open glass skylight, smart ambient lighting, premium stairs, lake proximity and modern aesthetics.',
        price: 85000,
        area: 'Bashundhara R/A',
        address: 'Bashundhara R/A, Dhaka',
        latitude: 23.7461,
        longitude: 90.3742,
        beds: 3,
        baths: 2,
        sizeSqFt: 1850,
        imageUrls: ['https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format&fit=crop&w=600&q=80'],
        isVerified: true,
        ownerId: 'o3',
        facilities: ['Parking', 'Lift', 'Backup', 'Wifi'],
        createdAt: DateTime.now(),
      ),
      PropertyModel(
        id: 'p4',
        title: 'Dhanmondi',
        description: 'Comfortable family apartment in Dhanmondi. Close to universities, schools, grocery centers and parks.',
        price: 65000,
        area: 'Dhanmondi',
        address: 'Road 27, Dhanmondi, Dhaka',
        latitude: 23.8722,
        longitude: 90.3842,
        beds: 3,
        baths: 3,
        sizeSqFt: 1400,
        imageUrls: ['https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=600&q=80'],
        isVerified: true,
        ownerId: 'o4',
        facilities: ['Wifi', 'Backup', 'Lift'],
        createdAt: DateTime.now(),
      ),
    ];
  }
}
