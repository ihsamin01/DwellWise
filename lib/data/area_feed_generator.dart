import 'dart:math';

import '../models/property_model.dart';
import 'bd_area_coordinates.dart';

const _img = 'https://images.unsplash.com/photo-';
const _q = '?auto=format&fit=crop&w=600&q=80';

const _photoIds = [
  '1522708323590-d24dbb6b0267',
  '1600585154340-be6161a56a0c',
  '1560448204-e02f11c3d0e2',
  '1502672260266-1c1ef2d93688',
  '1512917774080-9991f1c4c750',
  '1493809842364-78817add7ffb',
  '1484154218962-a197022b5858',
  '1567767292278-a4f21aa2d36e',
];

const _titlePrefixes = [
  'Cozy Apartment in',
  'Family Flat near',
  'Modern 2-Bed in',
  'Bachelor Sublet in',
  'Spacious Rental in',
  'Furnished Flat in',
  'Affordable Room in',
  'Premium Apartment in',
  'Sunny Studio in',
  'Well-lit Flat near',
  'Peaceful Home in',
  'Renovated Flat in',
];

/// Must match `SearchFiltersProvider.propertyTypes`, otherwise a type filter
/// can never match a generated listing.
const _types = ['Family', 'Bachelor', 'Office room', 'Sublet', 'Hostel'];
const _ownerIds = ['o1', 'o3', 'o5', 'o6', 'o7', 'o8', 'o9', 'o10', 'o12', 'o13'];
const _facilityPool = ['Wifi', 'Gas', 'Lift', 'Parking', 'Security', 'Backup', 'CCTV'];
const _months = ['August', 'September', 'October', 'November'];

String _slug(String s) =>
    s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-|-$'), '');

/// Generates [count] dummy rental listings located in [area] (a free-text area
/// like "Banani, Dhaka"), so the AI Recommended feed always has enough posts
/// around the user's location.
///
/// Coordinates come from [coordinatesFor] with a small jitter, so each listing's
/// map pin lands in the real neighbourhood its address names. Output is
/// deterministic per area (a refresh keeps the same listings; a new area
/// regenerates them). Every id is prefixed `ai-` for easy replacement.
List<PropertyModel> generateAreaProperties(String area, {int count = 12}) {
  final rng = Random(area.toLowerCase().hashCode);
  final slug = _slug(area);
  final now = DateTime.now();
  final (baseLat, baseLng) = coordinatesFor(area);

  // Short label for titles: the most specific part, e.g. "Banani" of
  // "Banani, Dhaka".
  final shortArea = area.split(',').first.trim().isEmpty
      ? area
      : area.split(',').first.trim();

  final list = <PropertyModel>[];

  for (var i = 0; i < count; i++) {
    final beds = 1 + rng.nextInt(4);
    final baths = 1 + rng.nextInt(3);
    final price = (7 + rng.nextInt(34)) * 1000.0; // 7,000 – 40,000
    final block = String.fromCharCode(65 + rng.nextInt(6)); // A–F

    final facilities = (_facilityPool.toList()..shuffle(rng))
        .take(3 + rng.nextInt(3))
        .toList();
    final img1 = _photoIds[rng.nextInt(_photoIds.length)];
    final img2 = _photoIds[rng.nextInt(_photoIds.length)];

    list.add(
      PropertyModel(
        id: 'ai-$slug-$i',
        title: '${_titlePrefixes[i % _titlePrefixes.length]} $shortArea',
        description:
            'A comfortable rental in $area with easy access to local markets, '
            'transport and schools. Ideal for those looking to live around $shortArea.',
        price: price,
        priceFor: 'Monthly',
        propertyType: _types[rng.nextInt(_types.length)],
        area: area,
        address: 'Block $block, Road ${1 + rng.nextInt(20)}, $area',
        // Jitter ~±0.0009° (≈100 m) around the real area centre so each pin
        // lands on the place its address names.
        latitude: baseLat + (rng.nextDouble() - 0.5) * 0.0018,
        longitude: baseLng + (rng.nextDouble() - 0.5) * 0.0018,
        beds: beds,
        baths: baths,
        balcony: rng.nextInt(3),
        sizeSqFt: (400 + rng.nextInt(1400)).toDouble(),
        availableFrom: _months[rng.nextInt(_months.length)],
        includedBills: rng.nextBool() ? const ['Gas bill'] : const [],
        imageUrls: ['$_img$img1$_q', '$_img$img2$_q'],
        isVerified: rng.nextBool(),
        ownerId: _ownerIds[rng.nextInt(_ownerIds.length)],
        facilities: facilities,
        createdAt: now.subtract(Duration(hours: i * 3)),
      ),
    );
  }
  return list;
}
