class Property {
  final String id;
  final String title;
  final String area;
  final double price;
  final double rating;
  final int beds;
  final int baths;
  final double sizeSqFt;
  final String imageUrl;
  final bool isVerified;
  final String ownerName;
  final String ownerPhone;
  final String ownerImage;
  final String description;
  final List<String> facilities;
  final double latitude;
  final double longitude;

  Property({
    required this.id,
    required this.title,
    required this.area,
    required this.price,
    required this.rating,
    required this.beds,
    required this.baths,
    required this.sizeSqFt,
    required this.imageUrl,
    required this.isVerified,
    required this.ownerName,
    required this.ownerPhone,
    required this.ownerImage,
    required this.description,
    required this.facilities,
    required this.latitude,
    required this.longitude,
  });
}
