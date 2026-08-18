import 'package:flutter_test/flutter_test.dart';

import 'package:dwell_wise/data/bd_locations.dart';
import 'package:dwell_wise/data/bd_locations_bn.dart';

/// True when [value] contains no Bengali codepoints — i.e. bnPlace fell
/// through to returning the English name unchanged.
bool isUntranslated(String value) =>
    !value.runes.any((r) => r >= 0x0980 && r <= 0x09FF);

void main() {
  group('bnPlace', () {
    test('translates every division, district and thana', () {
      final untranslated = <String>[];

      for (final division in bdDivisions.keys) {
        if (isUntranslated(bnPlace(division))) untranslated.add(division);

        for (final entry in bdDivisions[division]!.entries) {
          if (isUntranslated(bnPlace(entry.key))) untranslated.add(entry.key);
          for (final thana in entry.value) {
            if (isUntranslated(bnPlace(thana))) untranslated.add(thana);
          }
        }
      }

      expect(untranslated, isEmpty,
          reason: 'no Bangla name for: ${untranslated.take(20).join(', ')}');
    });

    test('translates every neighbourhood area', () {
      final untranslated = <String>[];

      for (final areas in bdThanaAreas.values) {
        for (final area in areas) {
          if (isUntranslated(bnPlace(area))) untranslated.add(area);
        }
      }

      expect(untranslated, isEmpty,
          reason: 'no Bangla name for: ${untranslated.take(20).join(', ')}');
    });

    test('composes suffixes rather than needing an entry each', () {
      expect(bnPlace('Bagerhat Sadar'), 'বাগেরহাট সদর');
      expect(bnPlace('Kotwali (Barishal)'), 'কোতোয়ালী (বরিশাল)');
    });

    test('writes numbers in Bangla digits', () {
      expect(bnPlace('Mirpur 10'), 'মিরপুর ১০');
      expect(bnPlace('Sector 13'), 'সেক্টর ১৩');
      expect(bnPlace('Mirpur 11.5'), 'মিরপুর ১১.৫');
    });

    test('leaves an unknown place alone instead of blanking it', () {
      expect(bnPlace('Nowhere Special'), 'Nowhere Special');
    });
  });
}
