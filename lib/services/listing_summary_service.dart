import 'package:google_generative_ai/google_generative_ai.dart';

import 'gemini_service.dart';

/// What the owner has filled in so far, in the order it reads best.
class ListingFacts {
  const ListingFacts({
    this.propertyType,
    this.area,
    this.availableFrom,
    this.beds,
    this.baths,
    this.balcony,
    this.price,
    this.priceFor,
    this.facilities = const [],
    this.includedBills = const [],
  });

  final String? propertyType;
  final String? area;
  final String? availableFrom;
  final int? beds;
  final int? baths;
  final int? balcony;
  final double? price;
  final String? priceFor;
  final List<String> facilities;
  final List<String> includedBills;

  /// Enough filled in to be worth describing.
  bool get isUsable => propertyType != null && area != null;

  @override
  bool operator ==(Object other) =>
      other is ListingFacts &&
      other.propertyType == propertyType &&
      other.area == area &&
      other.availableFrom == availableFrom &&
      other.beds == beds &&
      other.baths == baths &&
      other.balcony == balcony &&
      other.price == price &&
      other.priceFor == priceFor &&
      other.facilities.join() == facilities.join() &&
      other.includedBills.join() == includedBills.join();

  @override
  int get hashCode => Object.hash(propertyType, area, availableFrom, beds,
      baths, balcony, price, priceFor, facilities.join(), includedBills.join());
}

/// Turns the form into the paragraph shown under "About this property".
class ListingSummaryService {
  final GeminiService _gemini = GeminiService();

  /// Built on the spot from the form alone, so the owner always sees a
  /// description straight away rather than waiting on the network.
  static String compose(ListingFacts f) {
    final rooms = <String>[
      if (f.beds != null) '${f.beds} bedroom${f.beds == 1 ? '' : 's'}',
      if (f.baths != null) '${f.baths} bathroom${f.baths == 1 ? '' : 's'}',
      if (f.balcony != null && f.balcony! > 0)
        '${f.balcony} balcon${f.balcony == 1 ? 'y' : 'ies'}',
    ];

    final buffer = StringBuffer()
      ..write('${f.propertyType ?? 'Property'} available');
    if (f.area != null) buffer.write(' in ${f.area}');
    if (f.availableFrom != null) buffer.write(' from ${f.availableFrom}');
    if (rooms.isNotEmpty) buffer.write(', with ${_list(rooms)}');
    if (f.price != null) {
      final period = (f.priceFor ?? 'Monthly').toLowerCase();
      buffer.write('. Rent is BDT ${f.price!.round()} $period');
      if (f.includedBills.isNotEmpty) {
        buffer.write(', ${_list(f.includedBills).toLowerCase()} included');
      }
    }
    if (f.facilities.isNotEmpty) {
      buffer.write('. The building has ${_list(f.facilities).toLowerCase()}');
    }
    return '${buffer.toString()}.';
  }

  /// Asks Gemini to word the same facts more naturally. Falls back to
  /// [compose] whenever the model is slow, unreachable or drifts off the
  /// facts — the description must never claim something unentered.
  Future<String> write(ListingFacts facts, {required bool bangla}) async {
    final plain = compose(facts);
    final model = await _gemini.model();
    if (model == null) return plain;

    final language = bangla
        ? 'Write it in Bangla, in Bangla script, with Bangla digits.'
        : 'Write it in English.';

    final prompt = '''
Write the "about this property" paragraph for a Bangladeshi rental listing.

$language
Two or three sentences, plain and factual, as the landlord would write it.
Use only the facts below — never invent a feature, a price, a room, a floor
or anything about the neighbourhood. Do not add a greeting, a heading, a
phone number or bullet points. Return the paragraph and nothing else.

Facts: $plain
''';

    try {
      final response = await model
          .generateContent([Content.text(prompt)])
          .timeout(const Duration(seconds: 6));
      final text = response.text?.trim();
      if (text != null && text.isNotEmpty) return text;
    } catch (_) {
      // The composed version is already good enough to ship.
    }
    return plain;
  }

  static String _list(List<String> parts) {
    if (parts.length == 1) return parts.first;
    return '${parts.sublist(0, parts.length - 1).join(', ')} and ${parts.last}';
  }
}
