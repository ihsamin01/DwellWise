/// Data model representing a real estate / rental listing in DwellWise.
class PropertyModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final String propertyType;
  final String area;
  final String address;
  final double latitude;
  final double longitude;
  final int beds;
  final int baths;
  final double sizeSqFt;
  final List<String> imageUrls;
  final bool isVerified;
  final String ownerId;
  final List<String> facilities;
  final DateTime createdAt;

  PropertyModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.propertyType = 'Apartment',
    required this.area,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.beds,
    required this.baths,
    required this.sizeSqFt,
    required this.imageUrls,
    required this.isVerified,
    required this.ownerId,
    required this.facilities,
    required this.createdAt,
  });

  /// Factory constructor to parse PropertyModel from JSON.
  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      propertyType: json['property_type'] as String? ?? 'Apartment',
      area: json['area'] as String? ?? '',
      address: json['address'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      beds: json['beds'] as int? ?? 0,
      baths: json['baths'] as int? ?? 0,
      sizeSqFt: (json['size_sqft'] as num?)?.toDouble() ?? 0.0,
      imageUrls: List<String>.from(json['image_urls'] ?? []),
      isVerified: json['is_verified'] as bool? ?? false,
      ownerId: json['owner_id'] as String? ?? '',
      facilities: List<String>.from(json['facilities'] ?? []),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Converts PropertyModel to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'property_type': propertyType,
      'area': area,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'beds': beds,
      'baths': baths,
      'size_sqft': sizeSqFt,
      'image_urls': imageUrls,
      'is_verified': isVerified,
      'owner_id': ownerId,
      'facilities': facilities,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
