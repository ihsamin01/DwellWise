import 'dart:math';
import '../models/property_model.dart';

/// Generates realistic, deterministic Bangladeshi rental listings for any
/// searched location. The same location always produces the same posts
/// (stable IDs), so saving / recently-viewed keep working across searches.
class MockSearchService {
  MockSearchService._();

  // Verified-reachable modest interior photos (same pool as the home feed).
  static const _imgBase = 'https://images.unsplash.com/photo-';
  static const _imgQ = '?auto=format&fit=crop&w=600&q=80';
  static const List<String> _photoPool = [
    '1493809842364-78817add7ffb',
    '1554995207-c18c203602cb',
    '1505691938895-1758d7feb511',
    '1540518614846-7eded433c457',
    '1484154218962-a197022b5858',
    '1502005229762-cf1b2da7c5d6',
    '1560448204-e02f11c3d0e2',
    '1524758631624-e2822e304c36',
    '1502672260266-1c1ef2d93688',
    '1522708323590-d24dbb6b0267',
    '1600607687939-ce8a6c25118c',
    '1600585154340-be6161a56a0c',
  ];

  /// Dhaka thanas with premium rents.
  static const _premiumThanas = {
    'Gulshan', 'Banani', 'Dhanmondi', 'Vatara', 'Kalabagan', 'Ramna',
  };

  /// Builds 5-8 listings for the selected location. [division] is required;
  /// deeper selections narrow the naming used in titles/addresses. When [type]
  /// is one of the user-facing categories (Family, Bachelor, Office room,
  /// Sublet, Hostel), only listings of that category are produced.
  static List<PropertyModel> generate({
    required String division,
    String district = '',
    String thana = '',
    String area = '',
    String type = '',
  }) {
    final locality = area.isNotEmpty
        ? area
        : (thana.isNotEmpty ? thana : (district.isNotEmpty ? district : division));
    final parentLine = _addressLine(division, district, thana, area);

    // Deterministic seed from the full location path (+ type).
    final seed = '$division|$district|$thana|$area|$type'.hashCode;
    final rng = Random(seed);

    final (minRent, maxRent) = _rentBand(division, district, thana);
    final count = 5 + rng.nextInt(4); // 5..8 posts

    final all = _templates(locality, parentLine);
    // Filter to the requested category; fall back to all if none match.
    final filtered = type.isEmpty
        ? all
        : all.where((t) => t.category == type).toList();
    final templates = filtered.isEmpty ? all : filtered;
    final results = <PropertyModel>[];
    for (var i = 0; i < count; i++) {
      final t = templates[i % templates.length];
      // Rent within band, shaped by template weight, rounded to 500.
      final span = maxRent - minRent;
      final raw = minRent + span * t.priceWeight * (0.75 + rng.nextDouble() * 0.5);
      final rent = ((raw / 500).round() * 500).clamp(3000, 120000).toDouble();

      // 3-4 photos rotated deterministically through the pool.
      final start = rng.nextInt(_photoPool.length);
      final photoCount = 3 + rng.nextInt(2);
      final photos = List.generate(
        photoCount,
        (j) => '$_imgBase${_photoPool[(start + j) % _photoPool.length]}$_imgQ',
      );

      results.add(PropertyModel(
        id: 's_${seed.toRadixString(16)}_$i',
        title: '${t.title}, $locality',
        description: t.description,
        price: rent,
        propertyType: t.category,
        area: locality,
        address: parentLine,
        latitude: 23.5 + rng.nextDouble(),
        longitude: 90.0 + rng.nextDouble(),
        beds: t.beds,
        baths: t.baths,
        sizeSqFt: t.sqft.toDouble(),
        imageUrls: photos,
        isVerified: rng.nextInt(3) != 0, // ~2/3 verified
        ownerId: 'so_${rng.nextInt(1000)}',
        facilities: t.facilities,
        // Stagger post times so "Newest" ordering and card dates are realistic.
        createdAt: DateTime.now().subtract(Duration(hours: i * 8 + rng.nextInt(10))),
      ));
    }
    return results;
  }

  static String _addressLine(String division, String district, String thana, String area) {
    final parts = <String>[
      if (area.isNotEmpty) area,
      if (thana.isNotEmpty) thana,
      if (district.isNotEmpty) district,
      if (district != division) division,
    ];
    return parts.join(', ');
  }

  /// (min, max) monthly rent band in BDT for the location tier.
  static (double, double) _rentBand(String division, String district, String thana) {
    if (district == 'Dhaka') {
      if (_premiumThanas.contains(thana)) return (25000, 65000);
      if (thana.isNotEmpty) return (9000, 30000); // Dhaka metro non-premium
      return (9000, 35000); // district-wide search
    }
    // Other metro/district-sadar cities.
    const metroDistricts = {
      'Chattogram', 'Sylhet', 'Rajshahi', 'Khulna', 'Barishal', 'Rangpur',
      'Mymensingh', 'Gazipur', 'Narayanganj', 'Cumilla', "Cox's Bazar",
    };
    if (metroDistricts.contains(district)) return (7000, 25000);
    return (4000, 15000); // smaller district towns and upazilas
  }

  static List<_ListingTemplate> _templates(String locality, String parentLine) => [
        _ListingTemplate(
          title: '2 Bed Family Flat',
          category: 'Family',
          beds: 2,
          baths: 2,
          sqft: 800,
          priceWeight: 0.55,
          facilities: const ['Gas', 'Lift', 'Security'],
          description:
              'Well-ventilated 2-bedroom family flat in $locality. Gas line, water reserve and 24/7 security. Two months advance required. Close to local bazar, schools and bus stop.',
        ),
        _ListingTemplate(
          title: 'Bachelor Sublet Room',
          category: 'Bachelor',
          beds: 1,
          baths: 1,
          sqft: 180,
          priceWeight: 0.25,
          facilities: const ['Wifi', 'Gas'],
          description:
              'Furnished single room for a working bachelor in $locality. Attached bath, shared kitchen. All utility bills included in rent. One month advance only.',
        ),
        _ListingTemplate(
          title: '3 Bed Family Flat',
          category: 'Family',
          beds: 3,
          baths: 2,
          sqft: 1100,
          priceWeight: 0.8,
          facilities: const ['Gas', 'Lift', 'Parking', 'Backup'],
          description:
              'Spacious 3-bedroom apartment with drawing-dining in $locality. South-facing balconies, generator backup and reserved parking. Family preferred. Service charge extra.',
        ),
        _ListingTemplate(
          title: 'Mess Seat for Students',
          category: 'Hostel',
          beds: 1,
          baths: 1,
          sqft: 120,
          priceWeight: 0.15,
          facilities: const ['Wifi', 'Gas'],
          description:
              'Seat rent in a clean student mess / hostel at $locality. Bed, table and almirah provided, khala available for cooking. Electricity and wifi bill included.',
        ),
        _ListingTemplate(
          title: 'Sublet for Small Family',
          category: 'Sublet',
          beds: 1,
          baths: 1,
          sqft: 350,
          priceWeight: 0.35,
          facilities: const ['Gas', 'Security'],
          description:
              'One room sublet with attached bath and kitchen access in $locality, suitable for a small family or couple. Separate entrance, water and gas included.',
        ),
        _ListingTemplate(
          title: 'Office Space / Room',
          category: 'Office room',
          beds: 2,
          baths: 1,
          sqft: 700,
          priceWeight: 0.6,
          facilities: const ['Lift', 'Backup', 'Security'],
          description:
              'Commercial office room in $locality, suitable for a startup or small office. Lift, generator backup and reception space. Near $parentLine main road.',
        ),
        _ListingTemplate(
          title: 'Bachelor Studio Room',
          category: 'Bachelor',
          beds: 1,
          baths: 1,
          sqft: 400,
          priceWeight: 0.45,
          facilities: const ['Wifi', 'Gas', 'Security'],
          description:
              'Compact studio setup in $locality with attached bath and kitchenette. Ideal for a single professional bachelor. Wifi ready, night guard on duty.',
        ),
        _ListingTemplate(
          title: '3 Bed Family Flat with Balcony',
          category: 'Family',
          beds: 3,
          baths: 3,
          sqft: 1250,
          priceWeight: 0.9,
          facilities: const ['Gas', 'Lift', 'Parking', 'Backup', 'Security'],
          description:
              'Bright corner-plot apartment in $locality with three balconies and tiled floors. Master bed with attached bath. Genuine owner post, no brokers.',
        ),
        _ListingTemplate(
          title: 'Girls Hostel Seat',
          category: 'Hostel',
          beds: 1,
          baths: 1,
          sqft: 130,
          priceWeight: 0.2,
          facilities: const ['Wifi', 'Gas', 'Security'],
          description:
              'Seat in a secure girls hostel at $locality. Three meals available, study desk and locker provided. CCTV and female warden on duty.',
        ),
        _ListingTemplate(
          title: 'Office Floor (Semi-Furnished)',
          category: 'Office room',
          beds: 3,
          baths: 2,
          sqft: 1200,
          priceWeight: 0.85,
          facilities: const ['Lift', 'Backup', 'Parking', 'Security'],
          description:
              'Semi-furnished office floor in $locality with partitions and conference space. Lift, parking and generator backup. Ready for immediate move-in.',
        ),
      ];
}

class _ListingTemplate {
  final String title;
  final String category; // one of: Family, Bachelor, Office room, Sublet, Hostel
  final int beds;
  final int baths;
  final int sqft;
  final double priceWeight; // 0..1 position within the location's rent band
  final List<String> facilities;
  final String description;

  const _ListingTemplate({
    required this.title,
    required this.category,
    required this.beds,
    required this.baths,
    required this.sqft,
    required this.priceWeight,
    required this.facilities,
    required this.description,
  });
}
