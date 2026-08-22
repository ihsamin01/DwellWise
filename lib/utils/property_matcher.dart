import 'dart:math' as math;

import '../models/property_model.dart';

/// What the user asked for, pulled out of their message.
///
/// Everything except [area] is optional: a requirement the user did not
/// mention simply does not count towards the score, rather than counting as a
/// miss.
class SearchIntent {
  const SearchIntent({
    this.area,
    this.propertyType,
    this.beds,
    this.baths,
    this.balcony,
    this.maxRent,
    this.facilities = const [],
    this.language = 'en',
  });

  /// Canonical English place name, e.g. 'ECB Chattar'.
  final String? area;

  /// One of Family, Bachelor, Office room, Sublet, Hostel.
  final String? propertyType;

  final int? beds;
  final int? baths;
  final int? balcony;

  /// Monthly budget in taka.
  final double? maxRent;

  /// Facility codes as stored on the listing: GAS, LIFT, CCTV, GARAGE.
  final List<String> facilities;

  /// Language the user wrote in — the reply is written back in it.
  final String language;

  bool get isBangla => language == 'bn';

  SearchIntent copyWith({
    String? area,
    String? propertyType,
    int? beds,
    int? baths,
    int? balcony,
    double? maxRent,
    List<String>? facilities,
    String? language,
  }) {
    return SearchIntent(
      area: area ?? this.area,
      propertyType: propertyType ?? this.propertyType,
      beds: beds ?? this.beds,
      baths: baths ?? this.baths,
      balcony: balcony ?? this.balcony,
      maxRent: maxRent ?? this.maxRent,
      facilities: facilities ?? this.facilities,
      language: language ?? this.language,
    );
  }

  Map<String, dynamic> toJson() => {
        if (area != null) 'area': area,
        if (propertyType != null) 'property_type': propertyType,
        if (beds != null) 'beds': beds,
        if (baths != null) 'baths': baths,
        if (balcony != null) 'balcony': balcony,
        if (maxRent != null) 'max_rent': maxRent,
        if (facilities.isNotEmpty) 'facilities': facilities,
      };
}

/// How well one listing answers an intent.
///
/// [matched] and [shortfalls] are computed here rather than left to the model
/// to describe, so the reasoning shown to the user is always a statement about
/// the row and never something the model inferred.
class MatchResult {
  const MatchResult({
    required this.property,
    required this.score,
    required this.matched,
    required this.shortfalls,
    this.overBudgetBy,
  });

  final PropertyModel property;

  /// 0–100, over the requirements the user actually stated.
  final double score;

  final List<String> matched;
  final List<String> shortfalls;

  /// Taka above the stated budget, or null when within it.
  final double? overBudgetBy;

  bool get isOverBudget => overBudgetBy != null && overBudgetBy! > 0;
}

/// Weights per requirement. Only the ones the user stated are counted, so a
/// vague request is not punished for the fields it left out.
const double _wBeds = 30;
const double _wBaths = 15;
const double _wBalcony = 10;
const double _wFacility = 10;
const double _wBudget = 25;

/// Whether [property] is the kind of place the user asked for.
///
/// Kept out of the score on purpose: someone asking for a sublet does not want
/// a family flat ranked slightly lower, they want it left out, and to be told
/// plainly if there are none.
bool matchesType(PropertyModel property, SearchIntent intent) {
  final wanted = intent.propertyType;
  if (wanted == null) return true;
  return property.propertyType.toLowerCase() == wanted.toLowerCase();
}

/// Credit for a count that is close but not exact — one short still answers
/// most of what was asked, three short does not.
double _countCredit(int wanted, int actual) {
  if (actual >= wanted) return 1.0;
  final gap = wanted - actual;
  if (gap == 1) return 0.6;
  if (gap == 2) return 0.25;
  return 0.0;
}

/// Credit for rent against a budget. Slightly over is still worth showing;
/// far over is not what was asked for.
double _budgetCredit(double budget, double price) {
  if (price <= budget) return 1.0;
  final over = (price - budget) / budget;
  if (over <= 0.10) return 0.6;
  if (over <= 0.25) return 0.3;
  return 0.0;
}

/// Scores [property] against [intent], with the reasons on both sides.
MatchResult scoreProperty(PropertyModel property, SearchIntent intent) {
  var earned = 0.0;
  var possible = 0.0;
  final matched = <String>[];
  final shortfalls = <String>[];

  if (intent.beds != null) {
    possible += _wBeds;
    final credit = _countCredit(intent.beds!, property.beds);
    earned += _wBeds * credit;
    if (credit == 1.0) {
      matched.add('${property.beds} bedrooms');
    } else {
      shortfalls.add('${property.beds} bedrooms, ${intent.beds} asked');
    }
  }

  if (intent.baths != null) {
    possible += _wBaths;
    final credit = _countCredit(intent.baths!, property.baths);
    earned += _wBaths * credit;
    if (credit == 1.0) {
      matched.add('${property.baths} bathrooms');
    } else {
      shortfalls.add('${property.baths} bathrooms, ${intent.baths} asked');
    }
  }

  if (intent.balcony != null) {
    possible += _wBalcony;
    final credit = _countCredit(intent.balcony!, property.balcony);
    earned += _wBalcony * credit;
    if (credit == 1.0) {
      matched.add('${property.balcony} balconies');
    } else {
      shortfalls.add('${property.balcony} balconies, ${intent.balcony} asked');
    }
  }

  // Property type is filtered before scoring, not weighted here: asking for a
  // sublet and being shown family flats is not a near miss, it is the wrong
  // thing. See matchesType.
  if (intent.propertyType != null) {
    matched.add(property.propertyType);
  }

  final facilities = property.facilities.map((f) => f.toUpperCase()).toSet();
  for (final wanted in intent.facilities) {
    possible += _wFacility;
    final has = facilities.contains(wanted.toUpperCase());
    earned += has ? _wFacility : 0;
    if (has) {
      matched.add(wanted.toLowerCase());
    } else {
      shortfalls.add('no ${wanted.toLowerCase()}');
    }
  }

  double? overBudgetBy;
  if (intent.maxRent != null && intent.maxRent! > 0) {
    possible += _wBudget;
    final credit = _budgetCredit(intent.maxRent!, property.price);
    earned += _wBudget * credit;
    if (property.price > intent.maxRent!) {
      overBudgetBy = property.price - intent.maxRent!;
      shortfalls.add('৳${overBudgetBy.round()} over budget');
    } else {
      matched.add('within budget');
    }
  }

  // Nothing was asked for beyond a location, so every listing in that location
  // answers the request equally.
  final score = possible == 0 ? 100.0 : (earned / possible) * 100;

  return MatchResult(
    property: property,
    score: score,
    matched: matched,
    shortfalls: shortfalls,
    overBudgetBy: overBudgetBy,
  );
}

/// Listings scoring at or above [threshold], best first.
List<MatchResult> rankProperties(
  List<PropertyModel> properties,
  SearchIntent intent, {
  double threshold = 50,
}) {
  final results = [
    for (final property in properties)
      if (matchesType(property, intent)) scoreProperty(property, intent),
  ]..removeWhere((r) => r.score < threshold);

  results.sort((a, b) {
    final byScore = b.score.compareTo(a.score);
    if (byScore != 0) return byScore;
    // Same score: the cheaper one is the better answer.
    return a.property.price.compareTo(b.property.price);
  });

  return results;
}

/// Great-circle distance in kilometres.
double distanceKm(double lat1, double lon1, double lat2, double lon2) {
  const earthRadiusKm = 6371.0;
  final dLat = _toRadians(lat2 - lat1);
  final dLon = _toRadians(lon2 - lon1);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_toRadians(lat1)) *
          math.cos(_toRadians(lat2)) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);
  return earthRadiusKm * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
}

double _toRadians(double degrees) => degrees * math.pi / 180;
