import '../models/rental_deal_model.dart';

/// Demo rental history powering the analytics dashboard.
///
/// Nothing in the app records a completed deal yet — `rental_requests` and
/// `transactions` exist in backend/supabase/migrations but are not wired up —
/// so these lists stand in for that data. Dates are relative to today so the
/// six-month chart always looks current.
///
/// Tenancies deliberately start and end at different times, some with a gap
/// before the next one begins, so the monthly chart rises and falls the way a
/// real rental portfolio does instead of climbing in a straight line.
///
/// To go live: replace [ownerDeals] / [renterDeals] with a Supabase query for
/// approved rental_requests joined to properties, mapped into [RentalDeal].
/// Every screen above this file keeps working unchanged.
class DemoDeals {
  DemoDeals._();

  /// Start of the calendar month [back] months ago.
  static DateTime _monthsAgo(int back) {
    final now = DateTime.now();
    return DateTime(now.year, now.month - back, 5);
  }

  /// Properties the user rented out to others.
  ///
  /// Across the last six months this works out to roughly
  /// 34k → 31k → 53k → 46k → 65k → 58k, so a lease ending pulls the line down
  /// before a new one picks it back up.
  static List<RentalDeal> get ownerDeals => [
        RentalDeal(
          id: 'od1',
          title: 'Office Space, Motijheel',
          titleBn: 'অফিস স্পেস, মতিঝিল',
          propertyType: 'Office room',
          area: 'Motijheel C/A, Dhaka',
          areaBn: 'মতিঝিল বা/এ, ঢাকা',
          counterpartName: 'Nexus Softworks',
          counterpartNameBn: 'নেক্সাস সফটওয়ার্কস',
          monthlyRent: 15000,
          startedOn: _monthsAgo(5),
          monthsBilled: 3,
          isActive: false,
        ),
        RentalDeal(
          id: 'od2',
          title: 'Family Flat, Mirpur 11',
          titleBn: 'ফ্যামিলি ফ্ল্যাট, মিরপুর ১১',
          propertyType: 'Flat',
          area: 'Mirpur 11, Dhaka',
          areaBn: 'মিরপুর ১১, ঢাকা',
          counterpartName: 'Rakibul Hasan',
          counterpartNameBn: 'রাকিবুল হাসান',
          monthlyRent: 13000,
          startedOn: _monthsAgo(5),
          monthsBilled: 5,
          isActive: false,
        ),
        RentalDeal(
          id: 'od3',
          title: 'Sublet Room, Farmgate',
          titleBn: 'সাবলেট রুম, ফার্মগেট',
          propertyType: 'Sublet',
          area: 'Indira Road, Farmgate, Dhaka',
          areaBn: 'ইন্দিরা রোড, ফার্মগেট, ঢাকা',
          counterpartName: 'Sabbir Ahmed',
          counterpartNameBn: 'সাব্বির আহমেদ',
          monthlyRent: 6000,
          startedOn: _monthsAgo(5),
          monthsBilled: 1,
          isActive: false,
        ),
        RentalDeal(
          id: 'od4',
          title: 'Bachelor Seat, Mohammadpur',
          titleBn: 'ব্যাচেলর সিট, মোহাম্মদপুর',
          propertyType: 'Seat Rent',
          area: 'Tajmahal Road, Mohammadpur, Dhaka',
          areaBn: 'তাজমহল রোড, মোহাম্মদপুর, ঢাকা',
          counterpartName: 'Imran Kabir',
          counterpartNameBn: 'ইমরান কবির',
          monthlyRent: 3500,
          startedOn: _monthsAgo(4),
          monthsBilled: 2,
          isActive: false,
        ),
        RentalDeal(
          id: 'od5',
          title: 'Family Flat, Dhanmondi 27',
          titleBn: 'ফ্যামিলি ফ্ল্যাট, ধানমন্ডি ২৭',
          propertyType: 'Flat',
          area: 'Road 27, Dhanmondi, Dhaka',
          areaBn: 'রোড ২৭, ধানমন্ডি, ঢাকা',
          counterpartName: 'Farhana Islam',
          counterpartNameBn: 'ফারহানা ইসলাম',
          monthlyRent: 22000,
          startedOn: _monthsAgo(3),
          monthsBilled: 4,
        ),
        RentalDeal(
          id: 'od6',
          title: 'Studio Apartment, Uttara 7',
          titleBn: 'স্টুডিও অ্যাপার্টমেন্ট, উত্তরা ৭',
          propertyType: 'Studio',
          area: 'Sector 7, Uttara, Dhaka',
          areaBn: 'সেক্টর ৭, উত্তরা, ঢাকা',
          counterpartName: 'Nafisa Tabassum',
          counterpartNameBn: 'নাফিসা তাবাসসুম',
          monthlyRent: 11000,
          startedOn: _monthsAgo(2),
          monthsBilled: 1,
          isActive: false,
        ),
        RentalDeal(
          id: 'od7',
          title: 'Office Room, Gulshan 1',
          titleBn: 'অফিস রুম, গুলশান ১',
          propertyType: 'Office room',
          area: 'Gulshan 1, Dhaka',
          areaBn: 'গুলশান ১, ঢাকা',
          counterpartName: 'Bright Consultancy',
          counterpartNameBn: 'ব্রাইট কনসালটেন্সি',
          monthlyRent: 20000,
          startedOn: _monthsAgo(1),
          monthsBilled: 2,
        ),
        RentalDeal(
          id: 'od8',
          title: 'Studio Apartment, Bashundhara R/A',
          titleBn: 'স্টুডিও অ্যাপার্টমেন্ট, বসুন্ধরা আ/এ',
          propertyType: 'Studio',
          area: 'Block C, Bashundhara R/A, Dhaka',
          areaBn: 'ব্লক সি, বসুন্ধরা আ/এ, ঢাকা',
          counterpartName: 'Tanjila Akter',
          counterpartNameBn: 'তানজিলা আক্তার',
          monthlyRent: 10000,
          startedOn: _monthsAgo(1),
          monthsBilled: 2,
        ),
        RentalDeal(
          id: 'od9',
          title: 'Sublet Room, Mirpur DOHS',
          titleBn: 'সাবলেট রুম, মিরপুর ডিওএইচএস',
          propertyType: 'Sublet',
          area: 'Avenue 3, Mirpur DOHS, Dhaka',
          areaBn: 'এভিনিউ ৩, মিরপুর ডিওএইচএস, ঢাকা',
          counterpartName: 'Jubayer Alam',
          counterpartNameBn: 'জুবায়ের আলম',
          monthlyRent: 6500,
          startedOn: _monthsAgo(0),
          monthsBilled: 1,
        ),
      ];

  /// Properties the user rented from others — one home at a time, with a
  /// cheaper stretch in the middle and a short office rental on top.
  static List<RentalDeal> get renterDeals => [
        RentalDeal(
          id: 'rd1',
          title: 'Family Flat, Mirpur 11',
          titleBn: 'ফ্যামিলি ফ্ল্যাট, মিরপুর ১১',
          propertyType: 'Flat',
          area: 'Road 3, Mirpur 11, Dhaka',
          areaBn: 'রোড ৩, মিরপুর ১১, ঢাকা',
          counterpartName: 'Abdul Karim',
          counterpartNameBn: 'আব্দুল করিম',
          monthlyRent: 13000,
          startedOn: _monthsAgo(5),
          monthsBilled: 2,
          isActive: false,
        ),
        RentalDeal(
          id: 'rd2',
          title: 'Bachelor Sublet Room, Farmgate',
          titleBn: 'ব্যাচেলর সাবলেট রুম, ফার্মগেট',
          propertyType: 'Sublet',
          area: 'Indira Road, Farmgate, Dhaka',
          areaBn: 'ইন্দিরা রোড, ফার্মগেট, ঢাকা',
          counterpartName: 'Mizanur Rahman',
          counterpartNameBn: 'মিজানুর রহমান',
          monthlyRent: 6000,
          startedOn: _monthsAgo(5),
          monthsBilled: 1,
          isActive: false,
        ),
        RentalDeal(
          id: 'rd3',
          title: 'Sublet Room, Mohammadpur',
          titleBn: 'সাবলেট রুম, মোহাম্মদপুর',
          propertyType: 'Sublet',
          area: 'Shyamoli, Mohammadpur, Dhaka',
          areaBn: 'শ্যামলী, মোহাম্মদপুর, ঢাকা',
          counterpartName: 'Salma Begum',
          counterpartNameBn: 'সালমা বেগম',
          monthlyRent: 7000,
          startedOn: _monthsAgo(3),
          monthsBilled: 2,
          isActive: false,
        ),
        RentalDeal(
          id: 'rd4',
          title: 'Modern Skyline Studio, Banani',
          titleBn: 'মডার্ন স্কাইলাইন স্টুডিও, বনানী',
          propertyType: 'Studio',
          area: 'Road 11, Banani, Dhaka',
          areaBn: 'রোড ১১, বনানী, ঢাকা',
          counterpartName: 'Shahriar Rahman',
          counterpartNameBn: 'শাহরিয়ার রহমান',
          monthlyRent: 17000,
          startedOn: _monthsAgo(2),
          monthsBilled: 3,
        ),
        RentalDeal(
          id: 'rd5',
          title: 'Office Room, Banani 11',
          titleBn: 'অফিস রুম, বনানী ১১',
          propertyType: 'Office room',
          area: 'Kemal Ataturk Ave, Banani, Dhaka',
          areaBn: 'কামাল আতাতুর্ক এভিনিউ, বনানী, ঢাকা',
          counterpartName: 'Rezwan Chowdhury',
          counterpartNameBn: 'রেজওয়ান চৌধুরী',
          monthlyRent: 12000,
          startedOn: _monthsAgo(1),
          monthsBilled: 1,
          isActive: false,
        ),
      ];
}
