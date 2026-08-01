/// Which side of a rental the signed-in user was on for a given deal.
enum DealSide { owner, renter }

/// One completed rental that went through the app: a property the user either
/// rented out (owner side) or rented (renter side).
///
/// [monthlyRent] is the sticker rent, [monthsBilled] is how many months the
/// deal has actually run, so [totalValue] is the money that really moved
/// rather than a single month's figure.
class RentalDeal {
  final String id;
  final String title;
  final String titleBn;

  /// Canonical English property type matching the 'type_<value>' keys in
  /// [AppStrings] (e.g. 'Flat', 'Office room', 'Studio', 'Sublet').
  final String propertyType;
  final String area;
  final String areaBn;

  /// Tenant name on owner-side deals, owner name on renter-side deals.
  final String counterpartName;
  final String counterpartNameBn;
  final double monthlyRent;
  final DateTime startedOn;
  final int monthsBilled;

  /// False once the tenancy has ended; active deals still count towards the
  /// running monthly figure.
  final bool isActive;

  const RentalDeal({
    required this.id,
    required this.title,
    required this.titleBn,
    required this.propertyType,
    required this.area,
    required this.areaBn,
    required this.counterpartName,
    required this.counterpartNameBn,
    required this.monthlyRent,
    required this.startedOn,
    required this.monthsBilled,
    this.isActive = true,
  });

  double get totalValue => monthlyRent * monthsBilled;

  String localizedTitle(bool bangla) => bangla && titleBn.isNotEmpty ? titleBn : title;
  String localizedArea(bool bangla) => bangla && areaBn.isNotEmpty ? areaBn : area;
  String localizedCounterpart(bool bangla) =>
      bangla && counterpartNameBn.isNotEmpty ? counterpartNameBn : counterpartName;
}

/// One bar on the monthly chart: the rent that was flowing in (or out) during
/// [month], plus how many deals were running that month.
///
/// [amountByType] splits that rent across property types so the bar can be
/// stacked — showing at a glance whether a month came from flats, studios or
/// sublets rather than one anonymous total.
class MonthlyPoint {
  final DateTime month;
  final double amount;
  final int deals;
  final Map<String, double> amountByType;

  const MonthlyPoint({
    required this.month,
    required this.amount,
    required this.deals,
    this.amountByType = const {},
  });
}

/// Every number the analytics dashboard shows, derived from a list of deals.
///
/// Keeping the maths here means the screen only renders, and swapping the
/// demo deals for real rows later changes nothing above this class.
class DealSummary {
  /// All the money that changed hands across every deal.
  final double totalValue;

  /// Rent still flowing every month from deals that are running right now.
  final double monthlyRecurring;
  final int dealCount;
  final int activeCount;
  final double averageRent;

  /// How many deals of each property type, biggest slice first.
  final Map<String, int> countByType;

  /// One entry per month, oldest first.
  final List<MonthlyPoint> monthly;

  const DealSummary({
    required this.totalValue,
    required this.monthlyRecurring,
    required this.dealCount,
    required this.activeCount,
    required this.averageRent,
    required this.countByType,
    required this.monthly,
  });

  factory DealSummary.from(List<RentalDeal> deals, {int months = 6}) {
    var totalValue = 0.0;
    var monthlyRecurring = 0.0;
    var activeCount = 0;
    final byType = <String, int>{};

    for (final deal in deals) {
      totalValue += deal.totalValue;
      if (deal.isActive) {
        monthlyRecurring += deal.monthlyRent;
        activeCount++;
      }
      byType[deal.propertyType] = (byType[deal.propertyType] ?? 0) + 1;
    }

    final sortedTypes = byType.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return DealSummary(
      totalValue: totalValue,
      monthlyRecurring: monthlyRecurring,
      dealCount: deals.length,
      activeCount: activeCount,
      averageRent: deals.isEmpty
          ? 0
          : deals.fold<double>(0, (sum, d) => sum + d.monthlyRent) / deals.length,
      countByType: Map.fromEntries(sortedTypes),
      monthly: _monthlyPoints(deals, months),
    );
  }

  /// Walks back [months] calendar months and sums the rent of every deal that
  /// was running in each one, so the chart shows the portfolio building up
  /// rather than a single spike on the day each deal was signed.
  static List<MonthlyPoint> _monthlyPoints(List<RentalDeal> deals, int months) {
    final now = DateTime.now();
    final points = <MonthlyPoint>[];

    for (var back = months - 1; back >= 0; back--) {
      final bucket = DateTime(now.year, now.month - back);
      var amount = 0.0;
      var running = 0;
      final byType = <String, double>{};

      for (final deal in deals) {
        final start = DateTime(deal.startedOn.year, deal.startedOn.month);
        final end = DateTime(deal.startedOn.year, deal.startedOn.month + deal.monthsBilled);
        if (!bucket.isBefore(start) && bucket.isBefore(end)) {
          amount += deal.monthlyRent;
          running++;
          byType[deal.propertyType] =
              (byType[deal.propertyType] ?? 0) + deal.monthlyRent;
        }
      }

      points.add(MonthlyPoint(
        month: bucket,
        amount: amount,
        deals: running,
        amountByType: byType,
      ));
    }

    return points;
  }
}
