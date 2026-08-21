import 'package:flutter_test/flutter_test.dart';

import 'package:dwell_wise/models/property_model.dart';
import 'package:dwell_wise/utils/property_matcher.dart';

PropertyModel makeProperty({
  required String id,
  int beds = 3,
  int baths = 3,
  int balcony = 2,
  double price = 20000,
  String type = 'Family',
  List<String> facilities = const [],
}) {
  return PropertyModel(
    id: id,
    title: 'Test $id',
    description: '',
    price: price,
    propertyType: type,
    area: 'ECB Chattar',
    address: 'ECB Chattar, Dhaka',
    latitude: 23.8320,
    longitude: 90.3980,
    beds: beds,
    baths: baths,
    balcony: balcony,
    sizeSqFt: 1000,
    imageUrls: const [],
    isVerified: true,
    ownerId: 'owner',
    facilities: facilities,
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  // The user's own example: 3 bedrooms, 3 bathrooms, 2 balconies.
  const intent = SearchIntent(
    area: 'ECB Chattar',
    beds: 3,
    baths: 3,
    balcony: 2,
  );

  group('scoreProperty', () {
    test('scores an exact match at 100', () {
      final result = scoreProperty(makeProperty(id: 'exact'), intent);
      expect(result.score, 100);
      expect(result.shortfalls, isEmpty);
    });

    test('keeps a close match well above the cut-off', () {
      // One bathroom short of what was asked.
      final result =
          scoreProperty(makeProperty(id: 'close', baths: 2), intent);
      expect(result.score, greaterThan(50));
      expect(result.shortfalls.single, contains('2 bathrooms'));
    });

    test('drops a listing that misses almost everything', () {
      final result = scoreProperty(
        makeProperty(id: 'far', beds: 1, baths: 1, balcony: 0),
        intent,
      );
      expect(result.score, lessThan(50));
    });

    test('ignores requirements the user never stated', () {
      // Only bedrooms asked for, so bathrooms cannot drag the score down.
      const bedsOnly = SearchIntent(area: 'ECB Chattar', beds: 3);
      final result =
          scoreProperty(makeProperty(id: 'beds', baths: 1, balcony: 0), bedsOnly);
      expect(result.score, 100);
    });

    test('credits a facility only when the listing has it', () {
      const wantsGas =
          SearchIntent(area: 'ECB Chattar', facilities: ['GAS']);
      final withGas = scoreProperty(
          makeProperty(id: 'gas', facilities: const ['GAS', 'LIFT']), wantsGas);
      final without = scoreProperty(makeProperty(id: 'nogas'), wantsGas);

      expect(withGas.score, 100);
      expect(withGas.matched, contains('gas'));
      expect(without.score, 0);
      expect(without.shortfalls, contains('no gas'));
    });
  });

  group('budget', () {
    const budget = SearchIntent(area: 'ECB Chattar', maxRent: 20000);

    test('flags how far over budget a listing is', () {
      final result = scoreProperty(makeProperty(id: 'over', price: 25000), budget);
      expect(result.isOverBudget, isTrue);
      expect(result.overBudgetBy, 5000);
    });

    test('ranks an in-budget listing above one at twice the price', () {
      final ranked = rankProperties(
        [
          makeProperty(id: 'expensive', price: 40000),
          makeProperty(id: 'affordable', price: 18000),
        ],
        budget,
      );
      expect(ranked.first.property.id, 'affordable');
    });
  });

  group('rankProperties', () {
    test('drops anything below the threshold and sorts best first', () {
      final ranked = rankProperties(
        [
          makeProperty(id: 'poor', beds: 1, baths: 1, balcony: 0),
          makeProperty(id: 'good', baths: 2),
          makeProperty(id: 'perfect'),
        ],
        intent,
      );

      expect(ranked.map((r) => r.property.id), ['perfect', 'good']);
    });

    test('breaks a tie on price', () {
      final ranked = rankProperties(
        [
          makeProperty(id: 'dearer', price: 30000),
          makeProperty(id: 'cheaper', price: 15000),
        ],
        intent,
      );
      expect(ranked.first.property.id, 'cheaper');
    });
  });

  test('distanceKm measures a known gap', () {
    // ECB Chattar to Banani is roughly 5 km.
    final km = distanceKm(23.8320, 90.3980, 23.7936, 90.4043);
    expect(km, greaterThan(3));
    expect(km, lessThan(7));
  });
}
