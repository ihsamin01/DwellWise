/// Lightweight profile info for a property owner, looked up by [PropertyModel.ownerId].
class OwnerInfo {
  final String id;
  final String name;
  final double rating;
  final int reviewCount;
  final bool isVerified;
  final String phone;

  const OwnerInfo({
    required this.id,
    required this.name,
    required this.rating,
    required this.reviewCount,
    required this.isVerified,
    required this.phone,
  });
}

/// Resolves a stable, distinct [OwnerInfo] for each listing's owner id.
class OwnerDirectory {
  OwnerDirectory._();

  static const Map<String, OwnerInfo> _known = {
    'o1': OwnerInfo(id: 'o1', name: 'Kamal Hossain', rating: 4.7, reviewCount: 31, isVerified: true, phone: '+8801711223344'),
    'o3': OwnerInfo(id: 'o3', name: 'Nasrin Sultana', rating: 4.6, reviewCount: 18, isVerified: true, phone: '+8801812223344'),
    'o5': OwnerInfo(id: 'o5', name: 'Jashim Uddin', rating: 4.5, reviewCount: 24, isVerified: true, phone: '+8801911667788'),
    'o6': OwnerInfo(id: 'o6', name: 'Shirin Akter', rating: 4.3, reviewCount: 12, isVerified: false, phone: '+8801611445566'),
    'o7': OwnerInfo(id: 'o7', name: 'Rashed Ahmed', rating: 4.2, reviewCount: 9, isVerified: false, phone: '+8801700000000'),
    'o8': OwnerInfo(id: 'o8', name: 'Moyna Begum', rating: 4.4, reviewCount: 15, isVerified: false, phone: '+8801511998877'),
    'o9': OwnerInfo(id: 'o9', name: 'Abdul Karim', rating: 4.6, reviewCount: 27, isVerified: true, phone: '+8801322334455'),
    'o10': OwnerInfo(id: 'o10', name: 'Farida Yasmin', rating: 4.1, reviewCount: 7, isVerified: true, phone: '+8801611009988'),
    'o11': OwnerInfo(id: 'o11', name: 'Delwar Hossain', rating: 4.0, reviewCount: 5, isVerified: false, phone: '+8801733221100'),
    'o12': OwnerInfo(id: 'o12', name: 'Ruma Chowdhury', rating: 4.8, reviewCount: 33, isVerified: true, phone: '+8801855667799'),
    'o13': OwnerInfo(id: 'o13', name: 'Shahin Alam', rating: 4.3, reviewCount: 14, isVerified: false, phone: '+8801944556677'),
    'o14': OwnerInfo(id: 'o14', name: 'Rina Parvin', rating: 4.2, reviewCount: 10, isVerified: false, phone: '+8801677889900'),
    'o15': OwnerInfo(id: 'o15', name: 'Mizanur Rahman', rating: 4.6, reviewCount: 21, isVerified: true, phone: '+8801399887766'),
    'o16': OwnerInfo(id: 'o16', name: 'Taslima Nasrin', rating: 4.7, reviewCount: 29, isVerified: true, phone: '+8801588776655'),
    'o17': OwnerInfo(id: 'o17', name: 'Habibur Rahman', rating: 4.1, reviewCount: 8, isVerified: false, phone: '+8801766554433'),
  };

  static const List<String> _fallbackNames = [
    'Anwar Hossain',
    'Salma Khatun',
    'Iqbal Kabir',
    'Nazma Begum',
    'Rafiqul Islam',
    'Shahana Pervin',
    'Mahmudul Hasan',
    'Rokeya Sultana',
    'Tariqul Islam',
    'Lutfa Rahman',
  ];

  /// Returns a stable owner profile for [ownerId]. Unknown ids (e.g. from
  /// randomly generated search results) deterministically hash into the
  /// fallback name pool so the same id always resolves to the same owner.
  static OwnerInfo forId(String ownerId) {
    final known = _known[ownerId];
    if (known != null) return known;

    final hash = ownerId.hashCode.abs();
    return OwnerInfo(
      id: ownerId,
      name: _fallbackNames[hash % _fallbackNames.length],
      rating: 3.8 + (hash % 12) / 10,
      reviewCount: 3 + (hash % 40),
      isVerified: hash.isEven,
      phone: '+8801${700000000 + (hash % 99999999)}',
    );
  }
}
