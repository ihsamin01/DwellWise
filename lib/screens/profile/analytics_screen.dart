import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_strings.dart';
import '../../data/demo_deals.dart';
import '../../models/rental_deal_model.dart';
import '../../widgets/property_card.dart' show formatWithCommas;

/// Analytics dashboard: how much the user earned as an owner and how much they
/// spent as a renter, split across two tabs.
///
/// Numbers come from [DemoDeals] for now — see that file for what to swap in
/// once completed deals are recorded in the database.
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          title: Text(AppStrings.t(context, 'p_analytics')),
          centerTitle: true,
          // The app bar is solid primary blue in both themes, so the tab bar
          // has to sit on white rather than the usual on-surface colours.
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
            unselectedLabelStyle:
                const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
            tabs: [
              Tab(text: AppStrings.t(context, 'an_tab_owner')),
              Tab(text: AppStrings.t(context, 'an_tab_renter')),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _DealsTab(side: DealSide.owner, deals: DemoDeals.ownerDeals),
            _DealsTab(side: DealSide.renter, deals: DemoDeals.renterDeals),
          ],
        ),
      ),
    );
  }
}

/// One tab's worth of dashboard: stat cards, a monthly bar chart, a property
/// type donut, and the deal list behind the numbers.
class _DealsTab extends StatelessWidget {
  final DealSide side;
  final List<RentalDeal> deals;

  const _DealsTab({required this.side, required this.deals});

  /// Green reads as money coming in, blue as money going out.
  Color _accent(AppColors colors) =>
      side == DealSide.owner ? const Color(0xff10B981) : colors.primary;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isOwner = side == DealSide.owner;

    if (deals.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            AppStrings.t(context, isOwner ? 'an_empty_owner' : 'an_empty_renter'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: colors.textSecondary),
          ),
        ),
      );
    }

    final summary = DealSummary.from(deals);
    final accent = _accent(colors);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                colors: colors,
                accent: accent,
                icon: isOwner ? Icons.account_balance_wallet_outlined : Icons.payments_outlined,
                label: AppStrings.t(context, isOwner ? 'an_earned_total' : 'an_spent_total'),
                value: _money(context, summary.totalValue),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                colors: colors,
                accent: accent,
                icon: Icons.trending_up,
                label: AppStrings.t(context, isOwner ? 'an_monthly_income' : 'an_monthly_rent'),
                value: _money(context, summary.monthlyRecurring),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                colors: colors,
                accent: accent,
                icon: isOwner ? Icons.vpn_key_outlined : Icons.home_work_outlined,
                label: AppStrings.t(context, isOwner ? 'an_deals_done' : 'an_rented_total'),
                value: AppStrings.digits(context, '${summary.dealCount}'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                colors: colors,
                accent: accent,
                icon: isOwner ? Icons.check_circle_outline : Icons.equalizer_outlined,
                label: AppStrings.t(context, isOwner ? 'an_active_now' : 'an_avg_rent'),
                value: isOwner
                    ? AppStrings.digits(context, '${summary.activeCount}')
                    : _money(context, summary.averageRent),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _ChartCard(
          colors: colors,
          title: AppStrings.t(context, isOwner ? 'an_income_trend' : 'an_spend_trend'),
          subtitle: AppStrings.t(context, 'an_last_months'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 190,
                child: _MonthlyBarChart(
                  points: summary.monthly,
                  types: summary.countByType.keys.toList(),
                  colors: colors,
                ),
              ),
              const SizedBox(height: 14),
              _TypeLegend(types: summary.countByType.keys.toList(), colors: colors),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _ChartCard(
          colors: colors,
          title: AppStrings.t(context, isOwner ? 'an_type_rented_out' : 'an_type_rented_in'),
          subtitle: '${AppStrings.digits(context, '${summary.dealCount}')} '
              '${AppStrings.t(context, isOwner ? 'an_recent_owner' : 'an_recent_renter')}',
          child: _TypeBreakdown(summary: summary, colors: colors),
        ),
        const SizedBox(height: 24),
        Text(
          AppStrings.t(context, isOwner ? 'an_recent_owner' : 'an_recent_renter'),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...deals.map((deal) => _DealTile(deal: deal, side: side, colors: colors)),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.info_outline, size: 14, color: colors.textSecondary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                AppStrings.t(context, 'an_demo_note'),
                style: TextStyle(fontSize: 11.5, color: colors.textSecondary),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// One colour per property type, shared by the stacked bars and the donut so
/// a colour means the same thing in both charts.
const _typePalette = [
  Color(0xff1877F2),
  Color(0xff10B981),
  Color(0xffF59E0B),
  Color(0xff8B5CF6),
  Color(0xffEF4444),
  Color(0xff06B6D4),
];

/// '৳12,000' with Bangla digits when the app is in Bangla.
String _money(BuildContext context, double amount) =>
    '৳${AppStrings.digits(context, formatWithCommas(amount))}';

/// Compact axis label: '৳48k' for anything from a thousand up.
String _compactMoney(BuildContext context, double amount) {
  if (amount >= 1000) {
    final thousands = amount / 1000;
    final text = thousands >= 10 || thousands == thousands.roundToDouble()
        ? thousands.round().toString()
        : thousands.toStringAsFixed(1);
    return '৳${AppStrings.digits(context, text)}k';
  }
  return '৳${AppStrings.digits(context, amount.round().toString())}';
}

String _monthLabel(BuildContext context, DateTime date) =>
    AppStrings.t(context, 'mshort_${date.month}');

/// Big number tile in the 2x2 grid at the top of each tab.
class _StatCard extends StatelessWidget {
  final AppColors colors;
  final Color accent;
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.colors,
    required this.accent,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accent, size: 19),
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Titled white card that any chart drops into.
class _ChartCard extends StatelessWidget {
  final AppColors colors;
  final String title;
  final String subtitle;
  final Widget child;

  const _ChartCard({
    required this.colors,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(fontSize: 12, color: colors.textSecondary)),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

/// Six-month rent bar chart, each bar stacked by property type.
class _MonthlyBarChart extends StatelessWidget {
  final List<MonthlyPoint> points;

  /// Property types in a fixed order, so a colour stays with the same type
  /// across every month and matches the donut below.
  final List<String> types;
  final AppColors colors;

  const _MonthlyBarChart({
    required this.points,
    required this.types,
    required this.colors,
  });

  /// Splits one month's rent into stacked segments, bottom to top.
  List<BarChartRodStackItem> _stack(MonthlyPoint point) {
    final items = <BarChartRodStackItem>[];
    var from = 0.0;

    for (var i = 0; i < types.length; i++) {
      final value = point.amountByType[types[i]] ?? 0;
      if (value <= 0) continue;
      items.add(BarChartRodStackItem(
        from,
        from + value,
        _typePalette[i % _typePalette.length],
      ));
      from += value;
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final peak = points.fold<double>(0, (max, p) => p.amount > max ? p.amount : max);
    // Round the top of the axis up to a clean number so the gridlines land on
    // readable values instead of the exact peak.
    final step = peak <= 0 ? 5000.0 : _niceStep(peak / 4);
    final maxY = step * 4;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => colors.textPrimary,
            tooltipBorderRadius: BorderRadius.circular(8),
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
              _money(context, rod.toY),
              TextStyle(
                color: colors.surface,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: step,
          getDrawingHorizontalLine: (_) => FlLine(
            color: colors.border.withOpacity(0.55),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              interval: step,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                return SideTitleWidget(
                  meta: meta,
                  space: 6,
                  child: Text(
                    _compactMoney(context, value),
                    style: TextStyle(fontSize: 10.5, color: colors.textSecondary),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= points.length) return const SizedBox.shrink();
                return SideTitleWidget(
                  meta: meta,
                  space: 6,
                  child: Text(
                    _monthLabel(context, points[index].month),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colors.textSecondary,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < points.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: points[i].amount,
                  width: 22,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  color: colors.primary,
                  rodStackItems: _stack(points[i]),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY,
                    color: colors.border.withOpacity(0.28),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// Rounds a raw axis step up to 1/2/5 x a power of ten.
  static double _niceStep(double raw) {
    var magnitude = 1.0;
    while (magnitude * 10 <= raw) {
      magnitude *= 10;
    }
    final normalized = raw / magnitude;
    final rounded = normalized <= 1
        ? 1.0
        : normalized <= 2
            ? 2.0
            : normalized <= 5
                ? 5.0
                : 10.0;
    return rounded * magnitude;
  }
}

/// Colour key for the stacked bars, wrapping onto as many lines as it needs.
class _TypeLegend extends StatelessWidget {
  final List<String> types;
  final AppColors colors;

  const _TypeLegend({required this.types, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 8,
      children: [
        for (var i = 0; i < types.length; i++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: _typePalette[i % _typePalette.length],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                AppStrings.t(context, 'type_${types[i]}'),
                style: TextStyle(fontSize: 11.5, color: colors.textSecondary),
              ),
            ],
          ),
      ],
    );
  }
}

/// Donut of property types with a legend beside it.
class _TypeBreakdown extends StatelessWidget {
  final DealSummary summary;
  final AppColors colors;

  const _TypeBreakdown({required this.summary, required this.colors});

  @override
  Widget build(BuildContext context) {
    final entries = summary.countByType.entries.toList();

    return Row(
      children: [
        SizedBox(
          width: 132,
          height: 132,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 40,
                  startDegreeOffset: -90,
                  sections: [
                    for (var i = 0; i < entries.length; i++)
                      PieChartSectionData(
                        value: entries[i].value.toDouble(),
                        color: _typePalette[i % _typePalette.length],
                        radius: 22,
                        showTitle: false,
                      ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppStrings.digits(context, '${summary.dealCount}'),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    AppStrings.t(context, 'an_total_short'),
                    style: TextStyle(fontSize: 10.5, color: colors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < entries.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _typePalette[i % _typePalette.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppStrings.t(context, 'type_${entries[i].key}'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13, color: colors.textPrimary),
                        ),
                      ),
                      Text(
                        AppStrings.digits(context, '${entries[i].value}'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// One row in the list of deals behind the charts.
class _DealTile extends StatelessWidget {
  final RentalDeal deal;
  final DealSide side;
  final AppColors colors;

  const _DealTile({required this.deal, required this.side, required this.colors});

  IconData get _icon {
    switch (deal.propertyType) {
      case 'Office room':
        return Icons.business_center_outlined;
      case 'Studio':
        return Icons.weekend_outlined;
      case 'Sublet':
        return Icons.meeting_room_outlined;
      case 'Seat Rent':
        return Icons.bed_outlined;
      default:
        return Icons.apartment_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bangla = AppStrings.isBangla(context);
    final statusColor =
        deal.isActive ? const Color(0xff10B981) : colors.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border.withOpacity(0.6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(_icon, color: colors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deal.localizedTitle(bangla),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${AppStrings.t(context, side == DealSide.owner ? 'an_tenant' : 'an_owner')}'
                  ' · ${deal.localizedCounterpart(bangla)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: colors.textSecondary),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        AppStrings.t(context, deal.isActive ? 'an_active' : 'an_ended'),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '${AppStrings.digits(context, '${deal.monthsBilled}')} '
                        '${AppStrings.t(context, 'an_months_suffix')}'
                        ' · ${_monthLabel(context, deal.startedOn)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11.5, color: colors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _money(context, deal.totalValue),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${_money(context, deal.monthlyRent)}/${AppStrings.t(context, 'an_months_suffix')}',
                style: TextStyle(fontSize: 10.5, color: colors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
