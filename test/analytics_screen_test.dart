import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:dwell_wise/models/rental_deal_model.dart';
import 'package:dwell_wise/data/demo_deals.dart';
import 'package:dwell_wise/providers/locale_provider.dart';
import 'package:dwell_wise/screens/profile/analytics_screen.dart';

Widget _wrap(Widget child, {AppLanguage language = AppLanguage.english}) {
  return ChangeNotifierProvider(
    create: (_) => LocaleProvider()..setLanguage(language),
    child: MaterialApp(home: child),
  );
}

/// Squeezes the test surface down to a common phone size, where the stat cards
/// and chart legend are tightest.
Future<void> _usePhoneScreen(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2280);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
}

void main() {
  group('DealSummary', () {
    test('totals only count months actually billed', () {
      final summary = DealSummary.from(DemoDeals.ownerDeals);
      final expected = DemoDeals.ownerDeals
          .fold<double>(0, (sum, d) => sum + d.monthlyRent * d.monthsBilled);

      expect(summary.totalValue, expected);
      expect(summary.dealCount, DemoDeals.ownerDeals.length);
    });

    test('monthly recurring ignores deals that have ended', () {
      final summary = DealSummary.from(DemoDeals.ownerDeals);
      final active = DemoDeals.ownerDeals.where((d) => d.isActive);

      expect(summary.activeCount, active.length);
      expect(
        summary.monthlyRecurring,
        active.fold<double>(0, (sum, d) => sum + d.monthlyRent),
      );
    });

    test('produces one chart point per month, oldest first', () {
      final summary = DealSummary.from(DemoDeals.renterDeals);

      expect(summary.monthly.length, 6);
      for (var i = 1; i < summary.monthly.length; i++) {
        expect(summary.monthly[i].month.isAfter(summary.monthly[i - 1].month), isTrue);
      }
    });

    test('the owner chart rises and falls instead of only climbing', () {
      final amounts = DealSummary.from(DemoDeals.ownerDeals)
          .monthly
          .map((p) => p.amount)
          .toList();

      final rises = <bool>[];
      for (var i = 1; i < amounts.length; i++) {
        rises.add(amounts[i] > amounts[i - 1]);
      }

      expect(rises.contains(true), isTrue, reason: 'chart should go up somewhere');
      expect(rises.contains(false), isTrue, reason: 'chart should dip somewhere');
    });

    test('each month splits into property types that add back up', () {
      final summary = DealSummary.from(DemoDeals.ownerDeals);

      for (final point in summary.monthly) {
        final stacked =
            point.amountByType.values.fold<double>(0, (sum, v) => sum + v);
        expect(stacked, point.amount);
      }
    });

    test('a busy month draws on more than one property type', () {
      final summary = DealSummary.from(DemoDeals.ownerDeals);
      final mixed = summary.monthly.where((p) => p.amountByType.length > 1);

      expect(mixed, isNotEmpty, reason: 'bars should show a mix, not one type');
    });

    test('demo rents stay in a believable Dhaka range', () {
      for (final deal in [...DemoDeals.ownerDeals, ...DemoDeals.renterDeals]) {
        expect(deal.monthlyRent, greaterThanOrEqualTo(3000));
        expect(deal.monthlyRent, lessThanOrEqualTo(25000));
      }
    });

    test('a deal only contributes to the months it was running', () {
      final deal = RentalDeal(
        id: 'x',
        title: 'Test flat',
        titleBn: '',
        propertyType: 'Flat',
        area: 'Dhaka',
        areaBn: '',
        counterpartName: 'Someone',
        counterpartNameBn: '',
        monthlyRent: 10000,
        startedOn: DateTime(DateTime.now().year, DateTime.now().month - 1, 5),
        monthsBilled: 2,
      );
      final summary = DealSummary.from([deal]);

      // Only the last two of the six buckets should carry the rent.
      expect(summary.monthly.where((p) => p.amount > 0).length, 2);
      expect(summary.monthly.last.amount, 10000);
      expect(summary.monthly.first.amount, 0);
    });
  });

  testWidgets('renders both tabs on a phone screen without overflow', (tester) async {
    await _usePhoneScreen(tester);
    await tester.pumpWidget(_wrap(const AnalyticsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('As owner'), findsOneWidget);
    expect(find.text('Total earned'), findsOneWidget);
    expect(find.text('Monthly income'), findsWidgets);

    await tester.tap(find.text('As renter'));
    await tester.pumpAndSettle();

    expect(find.text('Total spent'), findsOneWidget);
    expect(find.text('Average rent'), findsOneWidget);
  });

  testWidgets('renders in Bangla, where labels are longest', (tester) async {
    await _usePhoneScreen(tester);
    await tester.pumpWidget(
      _wrap(const AnalyticsScreen(), language: AppLanguage.bangla),
    );
    await tester.pumpAndSettle();

    expect(find.text('মালিক হিসেবে'), findsOneWidget);
    expect(find.text('মোট আয়'), findsOneWidget);

    await tester.tap(find.text('ভাড়াটে হিসেবে'));
    await tester.pumpAndSettle();

    expect(find.text('মোট খরচ'), findsOneWidget);

    // The deal tiles sit below the fold and carry the longest Bangla strings.
    await tester.dragUntilVisible(
      find.textContaining('ডেমো ডেটা'),
      find.byType(ListView).first,
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('ডেমো ডেটা'), findsOneWidget);
  });

  testWidgets('scrolls to the deal list at the bottom of a tab', (tester) async {
    await _usePhoneScreen(tester);
    await tester.pumpWidget(_wrap(const AnalyticsScreen()));
    await tester.pumpAndSettle();

    await tester.dragUntilVisible(
      find.textContaining('Demo data'),
      find.byType(ListView).first,
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Demo data'), findsOneWidget);
  });
}
