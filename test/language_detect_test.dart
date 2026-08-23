import 'package:flutter_test/flutter_test.dart';

import 'package:dwell_wise/utils/language_detect.dart';

void main() {
  group('detectLanguage', () {
    test('reads Bengali script as Bangla', () {
      expect(detectLanguage('আমার ৩ রুমের বাসা দরকার'), 'bn');
    });

    test('reads romanised Bangla as Bangla', () {
      // The case that shipped broken: answered in English because the letters
      // are Latin.
      expect(detectLanguage('mirpur 12 er ashepashe'), 'bn');
      expect(detectLanguage('ki khobor tomar'), 'bn');
      expect(
        detectLanguage('amar ekta sublet basha dorkar'),
        'bn',
      );
    });

    test('reads English as English', () {
      expect(detectLanguage('I need a three bedroom flat in Banani'), 'en');
      expect(detectLanguage('hello'), 'en');
      expect(detectLanguage('Bachelor room in Mirpur 10 under 8000'), 'en');
    });

    test('does not flip on an English sentence with a stray match', () {
      // 'ar' and 'na' appear in English words often enough to matter.
      expect(
        detectLanguage(
          'I am looking for a large apartment near the lake with parking',
        ),
        'en',
      );
    });
  });
}
