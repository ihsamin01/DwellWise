/// Best-effort gender guess used only to pick a default profile avatar when the
/// user has not uploaded a photo. It is a heuristic over common Bangladeshi
/// name tokens — never treated as authoritative, and it falls back to a neutral
/// avatar when unsure.
enum Gender { male, female, unknown }

const List<String> _femaleTokens = [
  'begum', 'khatun', 'akter', 'akhtar', 'sultana', 'nasrin', 'fatema',
  'fatima', 'ayesha', 'aisha', 'rahima', 'parvin', 'parveen', 'yasmin',
  'jasmin', 'khanam', 'bibi', 'shirin', 'farida', 'nusrat', 'jahan',
  'tania', 'sadia', 'sumaiya', 'jannat', 'anika', 'nabila', 'bristy',
  'oishi', 'tisha', 'samia', 'sanjida', 'labiba', 'raisa', 'meherin',
  'ruma', 'moyna', 'rina', 'parvin', 'mitu', 'mou', 'nipa', 'poly',
];

const List<String> _maleTokens = [
  'mohammad', 'mohammed', 'muhammad', 'md', 'abdul', 'abul', 'hossain',
  'hussain', 'rahman', 'khan', 'uddin', 'islam', 'ahmed', 'ahmad',
  'kamal', 'jashim', 'rashed', 'karim', 'delwar', 'shahin', 'mizan',
  'mizanur', 'sarwar', 'faruk', 'farooq', 'rakib', 'sakib', 'tanvir',
  'sabbir', 'nayeem', 'naeem', 'imran', 'arafat', 'alam', 'anwar',
  'shahriar', 'tariq', 'raihan', 'fahim', 'sohel', 'jubayer', 'hasan',
];

/// Guesses a [Gender] from [name] using the token lists above.
Gender guessGender(String name) {
  final words = name.toLowerCase().split(RegExp(r'[\s.]+'));
  for (final w in words) {
    if (_femaleTokens.contains(w)) return Gender.female;
  }
  for (final w in words) {
    if (_maleTokens.contains(w)) return Gender.male;
  }
  return Gender.unknown;
}

/// A gender-appropriate avatar emoji used when there is no uploaded photo.
String genderAvatarEmoji(String name) {
  switch (guessGender(name)) {
    case Gender.male:
      return '👨';
    case Gender.female:
      return '👩';
    case Gender.unknown:
      return '🧑';
  }
}

/// Picks the avatar image asset. Uses the explicit [gender] chosen at
/// registration when available, otherwise falls back to guessing from [name].
String genderAvatarAsset(String? gender, String name) {
  final g = gender?.toLowerCase();
  if (g == 'female') return 'assets/avatars/female.svg';
  if (g == 'male') return 'assets/avatars/male.svg';
  return guessGender(name) == Gender.female
      ? 'assets/avatars/female.svg'
      : 'assets/avatars/male.svg';
}
