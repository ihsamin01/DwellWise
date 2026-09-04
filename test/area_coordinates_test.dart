import 'package:flutter_test/flutter_test.dart';
import 'package:dwell_wise/data/bd_area_coordinates.dart';

/// Roughly how far apart two points are, in kilometres.
double _km(
    (double, double) a, (double, double) b) {
  final dLat = (a.$1 - b.$1) * 111;
  final dLng = (a.$2 - b.$2) * 102;
  return (dLat * dLat + dLng * dLng) < 0 ? 0 : (dLat * dLat + dLng * dLng);
}

void main() {
  test('a landmark resolves to itself, not the middle of the city', () {
    final du = tryCoordinatesFor('Dhaka University')!;
    final centre = bdAreaCoordinates['dhaka']!;
    expect(du, isNot(centre));

    // It should sit beside the places people name around it.
    expect(_km(du, bdAreaCoordinates['nilkhet']!), lessThan(_km(du, centre)));
    expect(_km(du, bdAreaCoordinates['new market']!),
        lessThan(_km(du, centre)));
  });

  test('the longer name wins over the one inside it', () {
    // "dhaka university" contains "dhaka"; the city must not win.
    expect(tryCoordinatesFor('Dhaka University'),
        isNot(bdAreaCoordinates['dhaka']));
    // "mirpur 1" sits inside "mirpur 12" as text but is a different place.
    expect(tryCoordinatesFor('Mirpur 12'), bdAreaCoordinates['mirpur 12']);
  });

  test('an unknown place is admitted rather than guessed', () {
    expect(tryCoordinatesFor('Qwertyville'), isNull);
    // The defaulting form still answers, for the map pin that needs one.
    expect(coordinatesFor('Qwertyville'), bdAreaCoordinates['dhaka']);
  });
}
