import '../models/property_model.dart';

/// Offline "AI Recommended" ranking: re-orders [properties] so the ones closest
/// to the signed-in user's [userAddress] (from their profile) come first.
///
/// It's a lightweight text-proximity score over each property's area/address
/// versus the user's address — an exact area match ranks highest, then partial
/// word overlaps. Ties keep the input order, so any existing sort (newest /
/// price) still applies within the same proximity band.
List<PropertyModel> recommendByLocation(
  List<PropertyModel> properties,
  String? userAddress,
) {
  if (userAddress == null || userAddress.trim().isEmpty) {
    return properties;
  }
  final addr = userAddress.toLowerCase();

  final indexed = <MapEntry<int, PropertyModel>>[
    for (var i = 0; i < properties.length; i++) MapEntry(i, properties[i]),
  ];

  indexed.sort((a, b) {
    final sa = _score(a.value, addr);
    final sb = _score(b.value, addr);
    if (sa != sb) return sb.compareTo(sa); // higher score first
    return a.key.compareTo(b.key); // stable: preserve incoming order
  });

  return indexed.map((e) => e.value).toList();
}

/// Whether any property sits in (or near) the user's area — used to decide if
/// the "near you" label should be shown.
bool hasNearbyMatch(List<PropertyModel> properties, String? userAddress) {
  if (userAddress == null || userAddress.trim().isEmpty) return false;
  final addr = userAddress.toLowerCase();
  return properties.any((p) => _score(p, addr) >= 20);
}

int _score(PropertyModel p, String addrLower) {
  final area = p.area.toLowerCase().trim();
  final pAddr = p.address.toLowerCase();
  var score = 0;

  // Whole area string appears in the user's address (e.g. "mirpur 10").
  if (area.isNotEmpty && addrLower.contains(area)) {
    score += 100;
  }

  // Area word overlap (e.g. "mirpur" shared between "Mirpur 10" and "Mirpur 11").
  for (final w in area.split(RegExp(r'\s+'))) {
    if (w.length > 2 && addrLower.contains(w)) score += 20;
  }

  // Any user-address token found in the property's area/address.
  for (final w in addrLower.split(RegExp(r'[\s,]+'))) {
    if (w.length > 2 && (area.contains(w) || pAddr.contains(w))) score += 5;
  }

  return score;
}
