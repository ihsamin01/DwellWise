/// Data model representing a real estate / rental listing in DwellWise.
class PropertyModel {
  final String id;
  final String title;
  final String description;

  /// Optional Bangla variants for demo/mock content so listings can render in
  /// Bangla when the app language is set to Bangla. Empty means "no Bangla
  /// copy provided" and the screens fall back to the English text.
  final String titleBn;
  final String addressBn;
  final String descriptionBn;
  final double price;

  /// Billing period the [price] applies to: 'Monthly', 'Weekly' or 'Daily'.
  final String priceFor;
  final String propertyType;
  final String area;
  final String address;
  final double latitude;
  final double longitude;
  final int beds;
  final int baths;

  /// Number of balconies. Defaults to 0 for older/mock listings.
  final int balcony;
  final double sizeSqFt;

  /// Month the unit becomes available (e.g. 'August'). Empty when unspecified.
  final String availableFrom;

  /// Utility bills bundled into the rent, e.g. ['Electricity bill', 'Gas bill'].
  final List<String> includedBills;
  final List<String> imageUrls;
  final bool isVerified;
  final String ownerId;
  final List<String> facilities;
  final DateTime createdAt;

  PropertyModel({
    required this.id,
    required this.title,
    required this.description,
    this.titleBn = '',
    this.addressBn = '',
    this.descriptionBn = '',
    required this.price,
    this.priceFor = 'Monthly',
    this.propertyType = 'Apartment',
    required this.area,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.beds,
    required this.baths,
    this.balcony = 0,
    required this.sizeSqFt,
    this.availableFrom = '',
    this.includedBills = const [],
    required this.imageUrls,
    required this.isVerified,
    required this.ownerId,
    required this.facilities,
    required this.createdAt,
  });

  /// Returns a copy with the given fields overridden (used e.g. to stagger
  /// mock listing post dates).
  PropertyModel copyWith({
    double? price,
    String? priceFor,
    bool? isVerified,
    DateTime? createdAt,
  }) {
    return PropertyModel(
      id: id,
      title: title,
      description: description,
      titleBn: titleBn,
      addressBn: addressBn,
      descriptionBn: descriptionBn,
      price: price ?? this.price,
      priceFor: priceFor ?? this.priceFor,
      propertyType: propertyType,
      area: area,
      address: address,
      latitude: latitude,
      longitude: longitude,
      beds: beds,
      baths: baths,
      balcony: balcony,
      sizeSqFt: sizeSqFt,
      availableFrom: availableFrom,
      includedBills: includedBills,
      imageUrls: imageUrls,
      isVerified: isVerified ?? this.isVerified,
      ownerId: ownerId,
      facilities: facilities,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Returns the Bangla text when [bangla] is true and a Bangla variant
  /// exists; otherwise the default (English) text.
  String localizedTitle(bool bangla) => bangla && titleBn.isNotEmpty ? titleBn : title;
  String localizedAddress(bool bangla) => bangla && addressBn.isNotEmpty ? addressBn : address;
  String localizedDescription(bool bangla) =>
      bangla && descriptionBn.isNotEmpty ? descriptionBn : description;

  /// Factory constructor to parse PropertyModel from JSON.
  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      priceFor: json['price_for'] as String? ?? 'Monthly',
      propertyType: json['property_type'] as String? ?? 'Apartment',
      area: json['area'] as String? ?? '',
      address: json['address'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      beds: json['beds'] as int? ?? 0,
      baths: json['baths'] as int? ?? 0,
      balcony: json['balcony'] as int? ?? 0,
      sizeSqFt: (json['size_sqft'] as num?)?.toDouble() ?? 0.0,
      availableFrom: json['available_from'] as String? ?? '',
      includedBills: List<String>.from(json['included_bills'] ?? []),
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
      'price_for': priceFor,
      'property_type': propertyType,
      'area': area,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'beds': beds,
      'baths': baths,
      'balcony': balcony,
      'size_sqft': sizeSqFt,
      'available_from': availableFrom,
      'included_bills': includedBills,
      'image_urls': imageUrls,
      'is_verified': isVerified,
      'owner_id': ownerId,
      'facilities': facilities,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
