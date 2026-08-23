/// Decides which language to answer in.
///
/// Not left to the model: it read "mirpur 12 er ashepashe" as English and
/// replied in English, because the words are in Latin letters. Someone writing
/// romanised Bangla is speaking Bangla and expects Bangla back.
library language_detect;

/// Common Bangla words as people type them in Latin letters. Function words
/// rather than nouns — 'basha' appears in English sentences here too, but
/// nobody writes 'ashepashe' in an English one.
const Set<String> _banglishMarkers = {
  'ache', 'ache?', 'achi', 'ai', 'amar', 'ami', 'amake', 'amader', 'apni',
  'apnar', 'ar', 'ashepashe', 'ashe', 'ashen', 'basa', 'basha', 'bashar',
  'beshi', 'bhalo', 'bolen', 'chai', 'chaile', 'chacchi', 'dao', 'dorkar',
  'dite', 'er', 'jonno', 'kache', 'kaj', 'kemon', 'khoj', 'khujchi', 'ki',
  'kichu', 'kintu', 'kom', 'kon', 'kotha', 'lagbe', 'moddhe', 'na', 'nai',
  'niye', 'onek', 'pashe', 'r', 'ruger', 'ruom', 'shathe', 'tader', 'taka',
  'tar', 'tomar', 'valo',
};

/// True when [text] contains Bengali script.
bool hasBengaliScript(String text) =>
    text.runes.any((r) => r >= 0x0980 && r <= 0x09FF);

/// 'bn' when the message is Bangla — in either script — otherwise 'en'.
String detectLanguage(String text) {
  if (hasBengaliScript(text)) return 'bn';

  final words = text
      .toLowerCase()
      .split(RegExp(r'[^a-z0-9]+'))
      .where((w) => w.isNotEmpty)
      .toList();
  if (words.isEmpty) return 'en';

  final hits = words.where(_banglishMarkers.contains).length;

  // One marker in a short message is enough ("ki khobor"), but a long English
  // sentence that happens to contain 'ar' or 'na' should not flip.
  return hits >= 1 && hits * 4 >= words.length ? 'bn' : 'en';
}
