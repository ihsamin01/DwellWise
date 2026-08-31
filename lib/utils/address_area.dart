import '../data/bd_area_coordinates.dart';

/// Names that read wrong in title case.
const Set<String> _shouted = {'dohs', 'r/a', 'ecb'};

/// Pulls the place name out of a free-text profile address, e.g.
/// "House 12, Road 5, Mirpur DOHS, Dhaka" gives "Mirpur DOHS".
///
/// The longest known place mentioned wins, so the neighbourhood is picked
/// over the city it sits in. Returns null when nothing recognisable is there.
String? areaFromAddress(String? address) {
  final text = address?.toLowerCase().trim();
  if (text == null || text.isEmpty) return null;

  String? best;
  for (final name in bdAreaCoordinates.keys) {
    if (!text.contains(name)) continue;
    if (best == null || name.length > best.length) best = name;
  }
  return best == null ? null : _display(best);
}

String _display(String name) => name
    .split(' ')
    .map((word) => _shouted.contains(word)
        ? word.toUpperCase()
        : word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1)}')
    .join(' ');
