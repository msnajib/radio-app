// Parses FM/AM frequency directly from a station name string.
//
// Radio Browser API embeds frequency in station names in various formats:
//   "Prambors FM Jakarta 102.2"  → FM 102.2 MHz
//   "88.0 Mustang FM Jakarta"    → FM 88.0 MHz
//   "Mustang 88 FM"              → FM 88.0 MHz
//   "101 Jak FM Streaming"       → FM 101.0 MHz
//   "100,8 Insania FM"           → FM 100.8 MHz (comma decimal)
//   "Radio Suara Al-Iman 846 AM" → AM 846 kHz
//
// Returns null for both if the name contains no parseable frequency.
({double? fm, int? am}) parseFrequencyFromName(String name) {
  // 1. Decimal number (dot or comma) that falls in FM range 88.0–108.0
  final decimalRe = RegExp(r'\b(\d{2,3})[.,](\d{1,2})\b');
  for (final m in decimalRe.allMatches(name)) {
    final freq = double.parse('${m.group(1)}.${m.group(2)}');
    if (freq >= 88.0 && freq <= 108.0) return (fm: freq, am: null);
  }

  // 2. Integer directly adjacent to "FM" keyword, e.g. "88 FM", "Mustang 88 FM"
  final fmAdjacentRe = RegExp(r'\b(\d{2,3})\s*FM\b', caseSensitive: false);
  final fmAdj = fmAdjacentRe.firstMatch(name);
  if (fmAdj != null) {
    final freq = double.parse(fmAdj.group(1)!);
    if (freq >= 88 && freq <= 108) return (fm: freq, am: null);
  }

  // 3. Integer at start of name where name also contains "FM", e.g. "101 Jak FM"
  if (RegExp(r'\bFM\b', caseSensitive: false).hasMatch(name)) {
    final leadingRe = RegExp(r'^\s*(\d{2,3})\b');
    final leading = leadingRe.firstMatch(name);
    if (leading != null) {
      final freq = double.parse(leading.group(1)!);
      if (freq >= 88 && freq <= 108) return (fm: freq, am: null);
    }
  }

  // 4. Integer followed by "AM" keyword in AM range 530–1700 kHz
  final amRe = RegExp(r'\b(\d{3,4})\s*AM\b', caseSensitive: false);
  final amMatch = amRe.firstMatch(name);
  if (amMatch != null) {
    final freq = int.parse(amMatch.group(1)!);
    if (freq >= 530 && freq <= 1700) return (fm: null, am: freq);
  }

  return (fm: null, am: null);
}
