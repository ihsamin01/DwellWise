import 'package:flutter_test/flutter_test.dart';
import 'package:dwell_wise/services/listing_summary_service.dart';

void main() {
  test('writes the facts the owner entered', () {
    final text = ListingSummaryService.compose(const ListingFacts(
      propertyType: 'Family',
      area: 'Mirpur DOHS',
      availableFrom: 'November',
      beds: 3,
      baths: 3,
      balcony: 2,
      price: 15000,
      priceFor: 'Monthly',
      facilities: ['LIFT', 'GAS', 'GARAGE'],
      includedBills: ['Water'],
    ));
    // ignore: avoid_print
    print(text);
    expect(text, contains('Mirpur DOHS'));
    expect(text, contains('15000'));
    expect(text, contains('November'));
  });

  test('leaves out what has not been filled in', () {
    final text = ListingSummaryService.compose(
      const ListingFacts(propertyType: 'Sublet', area: 'Banani', beds: 1),
    );
    // ignore: avoid_print
    print(text);
    expect(text, isNot(contains('bathroom')));
    expect(text, isNot(contains('Rent')));
    expect(text, contains('1 bedroom'));
  });
}
