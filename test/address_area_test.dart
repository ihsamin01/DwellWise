import 'package:flutter_test/flutter_test.dart';
import 'package:dwell_wise/utils/address_area.dart';

void main() {
  test('picks the neighbourhood over the city', () {
    expect(areaFromAddress('House 12, Road 5, Mirpur DOHS, Dhaka'),
        'Mirpur DOHS');
    expect(areaFromAddress('Flat 4B, Banani, Dhaka-1213'), 'Banani');
  });

  test('reads an address written without commas', () {
    expect(areaFromAddress('45 no road uttara west dhaka'), 'Uttara West');
  });

  test('gives nothing when there is no place it knows', () {
    expect(areaFromAddress(''), isNull);
    expect(areaFromAddress(null), isNull);
    expect(areaFromAddress('House 9, Road 2'), isNull);
  });
}
