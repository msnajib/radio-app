// Station data verified from Wikipedia EN (March 2026) and AsiaWaves.net (Nov 2025).
// Stations are split into per-city lists so adding more frequencies later is easy:
// just append to the relevant city list and re-run analyze — no other file changes.
//
// Coverage status:
//   Jakarta      FM 87.6–107.7  COMPLETE     AM complete
//   Surabaya     FM 87.7–95.2   PARTIAL      AM complete
//   Semarang     FM 87.8–96.1   PARTIAL      AM complete
//   Bandung      FM 87.7–93.7   PARTIAL      AM complete
//   Yogyakarta   FM 87.9–95.8   PARTIAL      AM complete
//   Medan        FM 88.0–91.6   PARTIAL      AM complete
//   Makassar, Bali, Solo, Malang — NOT YET VERIFIED

import 'frequencies.dart';

class LocalStation {
  final String name;
  final double frequency; // MHz for FM, kHz for AM
  final String city;
  final String genre;
  final Band band;

  const LocalStation({
    required this.name,
    required this.frequency,
    required this.city,
    required this.genre,
    required this.band,
  });

  double? get fmFrequency => band == Band.fm ? frequency : null;
  int? get amFrequency => band == Band.am ? frequency.toInt() : null;
}

// ── JAKARTA ─────────────────────────────────────────────────────────────────
// Source: Wikipedia EN (March 2026) — COMPLETE
const _jakarta = [
  LocalStation(name: 'The Rockin Life',            frequency: 87.6,  city: 'Jakarta', genre: 'hot_ac',      band: Band.fm),
  LocalStation(name: 'Mustang 88 FM',              frequency: 88.0,  city: 'Jakarta', genre: 'top40',       band: Band.fm),
  LocalStation(name: 'Global Radio',               frequency: 88.4,  city: 'Jakarta', genre: 'pop',         band: Band.fm),
  LocalStation(name: 'RRI Programa 3',             frequency: 88.8,  city: 'Jakarta', genre: 'news',        band: Band.fm),
  LocalStation(name: 'Campursari FM',              frequency: 89.2,  city: 'Jakarta', genre: 'dangdut',     band: Band.fm),
  LocalStation(name: 'Publica FM',                 frequency: 89.6,  city: 'Jakarta', genre: 'hot_ac',      band: Band.fm),
  LocalStation(name: 'Radio Elshinta',             frequency: 90.0,  city: 'Jakarta', genre: 'news',        band: Band.fm),
  LocalStation(name: 'VOKS Radio',                 frequency: 90.4,  city: 'Jakarta', genre: 'hot_ac',      band: Band.fm),
  LocalStation(name: 'OZ Radio',                   frequency: 90.8,  city: 'Jakarta', genre: 'hot_ac',      band: Band.fm),
  LocalStation(name: 'RRI Programa 1',             frequency: 91.2,  city: 'Jakarta', genre: 'news',        band: Band.fm),
  LocalStation(name: 'Indika FM',                  frequency: 91.6,  city: 'Jakarta', genre: 'hot_ac',      band: Band.fm),
  LocalStation(name: 'Radio Sonora',               frequency: 92.0,  city: 'Jakarta', genre: 'news',        band: Band.fm),
  LocalStation(name: 'PAS FM',                     frequency: 92.4,  city: 'Jakarta', genre: 'business',    band: Band.fm),
  LocalStation(name: 'RRI Programa 4',             frequency: 92.8,  city: 'Jakarta', genre: 'culture',     band: Band.fm),
  LocalStation(name: 'Hot FM',                     frequency: 93.2,  city: 'Jakarta', genre: 'dangdut',     band: Band.fm),
  LocalStation(name: 'KISI FM',                    frequency: 93.4,  city: 'Jakarta', genre: 'top40',       band: Band.fm),
  LocalStation(name: 'Mersi FM',                   frequency: 93.9,  city: 'Jakarta', genre: 'dangdut',     band: Band.fm),
  LocalStation(name: 'Good Radio',                 frequency: 94.3,  city: 'Jakarta', genre: 'top40',       band: Band.fm),
  LocalStation(name: 'MG Radio',                   frequency: 94.7,  city: 'Jakarta', genre: 'news',        band: Band.fm),
  LocalStation(name: 'Kis FM',                     frequency: 95.1,  city: 'Jakarta', genre: 'hot_ac',      band: Band.fm),
  LocalStation(name: 'RASfm',                      frequency: 95.5,  city: 'Jakarta', genre: 'religious',   band: Band.fm),
  LocalStation(name: 'Smart FM',                   frequency: 95.9,  city: 'Jakarta', genre: 'business',    band: Band.fm),
  LocalStation(name: 'RPK FM',                     frequency: 96.3,  city: 'Jakarta', genre: 'religious',   band: Band.fm),
  LocalStation(name: 'IMI Radio',                  frequency: 96.7,  city: 'Jakarta', genre: 'classic_hits',band: Band.fm),
  LocalStation(name: 'RDI',                        frequency: 97.1,  city: 'Jakarta', genre: 'dangdut',     band: Band.fm),
  LocalStation(name: 'Motion Radio',               frequency: 97.5,  city: 'Jakarta', genre: 'top40',       band: Band.fm),
  LocalStation(name: 'FeMale Radio',               frequency: 97.9,  city: 'Jakarta', genre: 'hot_ac',      band: Band.fm),
  LocalStation(name: 'Mandarin Station',           frequency: 98.3,  city: 'Jakarta', genre: 'pop',         band: Band.fm),
  LocalStation(name: 'Gen FM',                     frequency: 98.7,  city: 'Jakarta', genre: 'top40',       band: Band.fm),
  LocalStation(name: 'Delta FM',                   frequency: 99.1,  city: 'Jakarta', genre: 'hot_ac',      band: Band.fm),
  LocalStation(name: 'Smooth FM',                  frequency: 99.5,  city: 'Jakarta', genre: 'hot_ac',      band: Band.fm),
  LocalStation(name: 'Z FM',                       frequency: 99.9,  city: 'Jakarta', genre: 'hot_ac',      band: Band.fm),
  LocalStation(name: 'Megaswara FM',               frequency: 100.8, city: 'Jakarta', genre: 'hot_ac',      band: Band.fm),
  LocalStation(name: 'Jak FM',                     frequency: 101.0, city: 'Jakarta', genre: 'hot_ac',      band: Band.fm),
  LocalStation(name: 'I-Swara',                    frequency: 101.4, city: 'Jakarta', genre: 'pop',         band: Band.fm),
  LocalStation(name: 'Prambors FM',                frequency: 102.2, city: 'Jakarta', genre: 'top40',       band: Band.fm),
  LocalStation(name: 'Camajaya FM',                frequency: 102.6, city: 'Jakarta', genre: 'classic_hits',band: Band.fm),
  LocalStation(name: 'Pop FM',                     frequency: 103.0, city: 'Jakarta', genre: 'pop',         band: Band.fm),
  LocalStation(name: 'DFM',                        frequency: 103.4, city: 'Jakarta', genre: 'dangdut',     band: Band.fm),
  LocalStation(name: 'X Channel',                  frequency: 103.8, city: 'Jakarta', genre: 'rock',        band: Band.fm),
  LocalStation(name: 'MS Tri FM',                  frequency: 104.2, city: 'Jakarta', genre: 'top40',       band: Band.fm),
  LocalStation(name: 'MNC Trijaya FM',             frequency: 104.6, city: 'Jakarta', genre: 'news',        band: Band.fm),
  LocalStation(name: 'RRI Programa 2',             frequency: 105.0, city: 'Jakarta', genre: 'hot_ac',      band: Band.fm),
  LocalStation(name: 'CBB FM',                     frequency: 105.4, city: 'Jakarta', genre: 'dangdut',     band: Band.fm),
  LocalStation(name: 'MOST Radio',                 frequency: 105.8, city: 'Jakarta', genre: 'classic_hits',band: Band.fm),
  LocalStation(name: 'Bens Radio',                 frequency: 106.2, city: 'Jakarta', genre: 'dangdut',     band: Band.fm),
  LocalStation(name: 'V Radio',                    frequency: 106.6, city: 'Jakarta', genre: 'top40',       band: Band.fm),
  LocalStation(name: 'Media Dangdut Radio',        frequency: 107.1, city: 'Jakarta', genre: 'dangdut',     band: Band.fm),
  LocalStation(name: 'Mandala Muda Radio',         frequency: 107.7, city: 'Jakarta', genre: 'top40',       band: Band.fm),
  // AM — 531 & 567 kHz below dial min (600), 1602 above dial max (1600): search-only
  LocalStation(name: 'Kabar Inklusif',             frequency: 531,   city: 'Jakarta', genre: 'news',        band: Band.am),
  LocalStation(name: 'Trax Jakarta',               frequency: 567,   city: 'Jakarta', genre: 'pop',         band: Band.am),
  LocalStation(name: 'Radio Samhan',               frequency: 630,   city: 'Jakarta', genre: 'talk',        band: Band.am),
  LocalStation(name: 'Radio Nam Nam Nam',          frequency: 666,   city: 'Jakarta', genre: 'talk',        band: Band.am),
  LocalStation(name: 'Radio Muara',                frequency: 693,   city: 'Jakarta', genre: 'talk',        band: Band.am),
  LocalStation(name: 'Radio Bharata',              frequency: 738,   city: 'Jakarta', genre: 'talk',        band: Band.am),
  LocalStation(name: 'Radio Rodja',                frequency: 756,   city: 'Jakarta', genre: 'religious',   band: Band.am),
  LocalStation(name: 'Buana Komunika',             frequency: 810,   city: 'Jakarta', genre: 'talk',        band: Band.am),
  LocalStation(name: 'Radio Berita Klasik',        frequency: 828,   city: 'Jakarta', genre: 'news',        band: Band.am),
  LocalStation(name: 'Persada Radio',              frequency: 1008,  city: 'Jakarta', genre: 'talk',        band: Band.am),
  LocalStation(name: 'Suara Khatulistiwa',         frequency: 1026,  city: 'Jakarta', genre: 'talk',        band: Band.am),
  LocalStation(name: 'Radio Cendrawasih',          frequency: 1062,  city: 'Jakarta', genre: 'talk',        band: Band.am),
  LocalStation(name: 'Radio UNTAR',                frequency: 1098,  city: 'Jakarta', genre: 'education',   band: Band.am),
  LocalStation(name: 'Radio Safari',               frequency: 1134,  city: 'Jakarta', genre: 'talk',        band: Band.am),
  LocalStation(name: 'Radio JJM',                  frequency: 1170,  city: 'Jakarta', genre: 'talk',        band: Band.am),
  LocalStation(name: 'IRS Radio',                  frequency: 1224,  city: 'Jakarta', genre: 'talk',        band: Band.am),
  LocalStation(name: 'Radio Rona MKB',             frequency: 1440,  city: 'Jakarta', genre: 'talk',        band: Band.am),
  LocalStation(name: 'Radio Angkatan Bersenjata',  frequency: 1494,  city: 'Jakarta', genre: 'news',        band: Band.am),
  LocalStation(name: 'Radio Masjid Sunda Kelapa',  frequency: 1530,  city: 'Jakarta', genre: 'religious',   band: Band.am),
  LocalStation(name: 'Hidupin Radio Network',      frequency: 1602,  city: 'Jakarta', genre: 'talk',        band: Band.am),
];

// ── SURABAYA ─────────────────────────────────────────────────────────────────
// Source: AsiaWaves.net (Nov 2025) — FM partial to 95.2 MHz
const _surabaya = [
  LocalStation(name: 'Voks Radio',                 frequency: 87.7,  city: 'Surabaya', genre: 'pop',        band: Band.fm),
  LocalStation(name: 'Radio Kota FM',              frequency: 88.1,  city: 'Surabaya', genre: 'pop',        band: Band.fm),
  LocalStation(name: 'Metro FM',                   frequency: 88.5,  city: 'Surabaya', genre: 'pop',        band: Band.fm),
  LocalStation(name: 'Smart FM Surabaya',          frequency: 88.9,  city: 'Surabaya', genre: 'news',       band: Band.fm),
  LocalStation(name: 'Prambors Surabaya',          frequency: 89.3,  city: 'Surabaya', genre: 'pop',        band: Band.fm),
  LocalStation(name: 'iSwara FM Surabaya',         frequency: 89.7,  city: 'Surabaya', genre: 'pop',        band: Band.fm),
  LocalStation(name: 'Media FM',                   frequency: 90.1,  city: 'Surabaya', genre: 'pop',        band: Band.fm),
  LocalStation(name: 'Ampel Denta',                frequency: 90.5,  city: 'Surabaya', genre: 'religious',  band: Band.fm),
  LocalStation(name: 'Global FM Surabaya',         frequency: 90.9,  city: 'Surabaya', genre: 'pop',        band: Band.fm),
  LocalStation(name: 'Suzana FM',                  frequency: 91.3,  city: 'Surabaya', genre: 'dangdut',    band: Band.fm),
  LocalStation(name: 'RRI Surabaya Ch 5',          frequency: 91.7,  city: 'Surabaya', genre: 'music',      band: Band.fm),
  LocalStation(name: 'Radio BFM',                  frequency: 92.9,  city: 'Surabaya', genre: 'pop',        band: Band.fm),
  LocalStation(name: 'El Victor FM',               frequency: 93.3,  city: 'Surabaya', genre: 'pop',        band: Band.fm),
  LocalStation(name: 'Suara Muslim',               frequency: 93.8,  city: 'Surabaya', genre: 'religious',  band: Band.fm),
  LocalStation(name: 'DJ FM',                      frequency: 94.8,  city: 'Surabaya', genre: 'pop',        band: Band.fm),
  LocalStation(name: 'RRI Pro 2 Surabaya',         frequency: 95.2,  city: 'Surabaya', genre: 'music',      band: Band.fm),
  // TODO: add 95.2+ MHz when verified
  // AM — 585 kHz below dial min (600): search-only
  LocalStation(name: 'RRI Surabaya Pro 4',         frequency: 585,   city: 'Surabaya', genre: 'news',       band: Band.am),
  LocalStation(name: 'Radio Suara al Iman',        frequency: 918,   city: 'Surabaya', genre: 'religious',  band: Band.am),
  LocalStation(name: 'RRI Surabaya Pro 3',         frequency: 999,   city: 'Surabaya', genre: 'news',       band: Band.am),
  LocalStation(name: 'Radio Yasmara',              frequency: 1152,  city: 'Surabaya', genre: 'talk',       band: Band.am),
];

// ── SEMARANG ─────────────────────────────────────────────────────────────────
// Source: AsiaWaves.net — FM partial to 96.1 MHz
const _semarang = [
  LocalStation(name: 'Radio Gaul',                 frequency: 87.8,  city: 'Semarang', genre: 'pop',        band: Band.fm),
  LocalStation(name: 'RRI Semarang Pro 4',         frequency: 88.2,  city: 'Semarang', genre: 'culture',    band: Band.fm),
  LocalStation(name: 'Radio Rhema FM',             frequency: 88.6,  city: 'Semarang', genre: 'religious',  band: Band.fm),
  LocalStation(name: 'RRI Semarang Pro 1',         frequency: 89.0,  city: 'Semarang', genre: 'news',       band: Band.fm),
  LocalStation(name: 'Maneuver Radio',             frequency: 89.4,  city: 'Semarang', genre: 'pop',        band: Band.fm),
  LocalStation(name: 'Radio Trijaya FM Semarang',  frequency: 89.8,  city: 'Semarang', genre: 'news',       band: Band.fm),
  LocalStation(name: 'iSwara FM Semarang',         frequency: 90.2,  city: 'Semarang', genre: 'pop',        band: Band.fm),
  LocalStation(name: 'Radio Elshinta Semarang',    frequency: 91.0,  city: 'Semarang', genre: 'news',       band: Band.fm),
  LocalStation(name: 'Radio Dangdut Indonesia Semarang', frequency: 91.8, city: 'Semarang', genre: 'dangdut', band: Band.fm),
  LocalStation(name: 'RRI Semarang Pro 3',         frequency: 92.2,  city: 'Semarang', genre: 'music',      band: Band.fm),
  LocalStation(name: 'Idola FM',                   frequency: 92.6,  city: 'Semarang', genre: 'pop',        band: Band.fm),
  LocalStation(name: 'C Radio',                    frequency: 93.4,  city: 'Semarang', genre: 'pop',        band: Band.fm),
  LocalStation(name: 'Radio Agape FM',             frequency: 94.5,  city: 'Semarang', genre: 'religious',  band: Band.fm),
  LocalStation(name: 'Good News FM',               frequency: 94.9,  city: 'Semarang', genre: 'religious',  band: Band.fm),
  LocalStation(name: 'RRI Semarang Pro 2',         frequency: 95.3,  city: 'Semarang', genre: 'music',      band: Band.fm),
  LocalStation(name: 'Fit Radio',                  frequency: 95.7,  city: 'Semarang', genre: 'sports',     band: Band.fm),
  LocalStation(name: 'Delta FM Semarang',          frequency: 96.1,  city: 'Semarang', genre: 'pop',        band: Band.fm),
  // TODO: add 96.1+ MHz when verified
  LocalStation(name: 'RRI Semarang Pro 4 AM',      frequency: 801,   city: 'Semarang', genre: 'news',       band: Band.am),
  LocalStation(name: 'Radio Mutiara Quran',        frequency: 1170,  city: 'Semarang', genre: 'religious',  band: Band.am),
];

// ── BANDUNG ──────────────────────────────────────────────────────────────────
// Source: AsiaWaves.net — FM partial to 93.7 MHz
// Excluded: 540 kHz AM (RRI Bandung Pro-4, off air Nov 2025)
const _bandung = [
  LocalStation(name: 'The Rockin Life Bandung',    frequency: 87.7,  city: 'Bandung', genre: 'hot_ac',      band: Band.fm),
  LocalStation(name: 'StudioEast Radio',           frequency: 88.1,  city: 'Bandung', genre: 'pop',         band: Band.fm),
  LocalStation(name: 'RRI Bandung Pro 3',          frequency: 88.5,  city: 'Bandung', genre: 'news',        band: Band.fm),
  LocalStation(name: 'Auto Radio',                 frequency: 88.9,  city: 'Bandung', genre: 'pop',         band: Band.fm),
  LocalStation(name: 'Radio Elshinta Bandung',     frequency: 89.3,  city: 'Bandung', genre: 'news',        band: Band.fm),
  LocalStation(name: 'Okezone Radio Bandung',      frequency: 89.7,  city: 'Bandung', genre: 'pop',         band: Band.fm),
  LocalStation(name: 'Radio Zora',                 frequency: 90.1,  city: 'Bandung', genre: 'pop',         band: Band.fm),
  LocalStation(name: 'Radio Cakra FM',             frequency: 90.5,  city: 'Bandung', genre: 'pop',         band: Band.fm),
  LocalStation(name: 'X-Channel Bandung',          frequency: 90.9,  city: 'Bandung', genre: 'rock',        band: Band.fm),
  LocalStation(name: 'Radio Trijaya FM Bandung',   frequency: 91.3,  city: 'Bandung', genre: 'news',        band: Band.fm),
  LocalStation(name: 'Voks Radio Bandung',         frequency: 91.7,  city: 'Bandung', genre: 'pop',         band: Band.fm),
  LocalStation(name: 'Radio Mei Sheng',            frequency: 92.1,  city: 'Bandung', genre: 'pop',         band: Band.fm),
  LocalStation(name: 'Maestro FM',                 frequency: 92.5,  city: 'Bandung', genre: 'pop',         band: Band.fm),
  LocalStation(name: 'Radio Sonora Bandung',       frequency: 93.3,  city: 'Bandung', genre: 'news',        band: Band.fm),
  LocalStation(name: 'Radio Paramuda',             frequency: 93.7,  city: 'Bandung', genre: 'pop',         band: Band.fm),
  // TODO: add 93.7+ MHz when verified
  LocalStation(name: 'Radio Barani',               frequency: 1116,  city: 'Bandung', genre: 'education',   band: Band.am),
  LocalStation(name: 'Radio Rodja Bandung',        frequency: 1476,  city: 'Bandung', genre: 'religious',   band: Band.am),
];

// ── YOGYAKARTA ───────────────────────────────────────────────────────────────
// Source: AsiaWaves.net — FM partial to 95.8 MHz
// Excluded AM: 1062 (Radio Bin Baz, off air), 1179 (Radio Unisia, off air)
const _yogyakarta = [
  LocalStation(name: 'Radio Dangdut Indonesia Yogya', frequency: 87.9, city: 'Yogyakarta', genre: 'dangdut', band: Band.fm),
  LocalStation(name: 'Radio Q',                    frequency: 88.3,  city: 'Yogyakarta', genre: 'pop',      band: Band.fm),
  LocalStation(name: 'iSwara FM Yogya',            frequency: 88.7,  city: 'Yogyakarta', genre: 'pop',      band: Band.fm),
  LocalStation(name: 'Radio Pesona Bara FM',       frequency: 89.1,  city: 'Yogyakarta', genre: 'pop',      band: Band.fm),
  LocalStation(name: 'JIZ FM',                     frequency: 89.5,  city: 'Yogyakarta', genre: 'pop',      band: Band.fm),
  LocalStation(name: 'Radio Sasando FM',           frequency: 90.3,  city: 'Yogyakarta', genre: 'pop',      band: Band.fm),
  LocalStation(name: 'UTY FM',                     frequency: 90.7,  city: 'Yogyakarta', genre: 'pop',      band: Band.fm),
  LocalStation(name: 'RRI Yogyakarta Pro 1',       frequency: 91.1,  city: 'Yogyakarta', genre: 'news',     band: Band.fm),
  LocalStation(name: 'Radio Thomson Jogja',        frequency: 91.9,  city: 'Yogyakarta', genre: 'pop',      band: Band.fm),
  LocalStation(name: 'Radio MQ FM',                frequency: 92.3,  city: 'Yogyakarta', genre: 'pop',      band: Band.fm),
  LocalStation(name: 'MBS FM',                     frequency: 92.7,  city: 'Yogyakarta', genre: 'pop',      band: Band.fm),
  LocalStation(name: 'Radio Argososro',            frequency: 93.2,  city: 'Yogyakarta', genre: 'pop',      band: Band.fm),
  LocalStation(name: 'Megaswara FM Jogja',         frequency: 93.8,  city: 'Yogyakarta', genre: 'pop',      band: Band.fm),
  LocalStation(name: 'Radio Persatuan',            frequency: 94.2,  city: 'Yogyakarta', genre: 'pop',      band: Band.fm),
  LocalStation(name: 'Kota Perak FM',              frequency: 94.6,  city: 'Yogyakarta', genre: 'pop',      band: Band.fm),
  LocalStation(name: 'Radio Masdha FM',            frequency: 95.0,  city: 'Yogyakarta', genre: 'pop',      band: Band.fm),
  LocalStation(name: 'Radio Yasika FM',            frequency: 95.4,  city: 'Yogyakarta', genre: 'pop',      band: Band.fm),
  LocalStation(name: 'Prambors Yogyakarta',        frequency: 95.8,  city: 'Yogyakarta', genre: 'top40',    band: Band.fm),
  // TODO: add 95.8+ MHz when verified
  LocalStation(name: 'Radio Suara Konco Tani',     frequency: 711,   city: 'Yogyakarta', genre: 'talk',     band: Band.am),
  LocalStation(name: 'Radio Swara Kenanga',        frequency: 783,   city: 'Yogyakarta', genre: 'talk',     band: Band.am),
  LocalStation(name: 'Radio Joss',                 frequency: 855,   city: 'Yogyakarta', genre: 'talk',     band: Band.am),
  LocalStation(name: 'RRI Yogyakarta Pro 4',       frequency: 1107,  city: 'Yogyakarta', genre: 'news',     band: Band.am),
  LocalStation(name: 'Radio Muhammadiyah',         frequency: 1395,  city: 'Yogyakarta', genre: 'religious',band: Band.am),
];

// ── MEDAN ─────────────────────────────────────────────────────────────────────
// Source: AsiaWaves.net — FM partial to 91.6 MHz
const _medan = [
  LocalStation(name: 'La Femme',                   frequency: 88.0,  city: 'Medan', genre: 'pop',           band: Band.fm),
  LocalStation(name: 'RRI Medan Pro 4',            frequency: 88.4,  city: 'Medan', genre: 'news',          band: Band.fm),
  LocalStation(name: 'RRI Medan Pro 3',            frequency: 88.8,  city: 'Medan', genre: 'news',          band: Band.fm),
  LocalStation(name: 'P FM',                       frequency: 89.2,  city: 'Medan', genre: 'pop',           band: Band.fm),
  LocalStation(name: 'iSwara FM Medan',            frequency: 89.6,  city: 'Medan', genre: 'pop',           band: Band.fm),
  LocalStation(name: 'Hot 90 FM',                  frequency: 90.0,  city: 'Medan', genre: 'pop',           band: Band.fm),
  LocalStation(name: 'Radio Sonara',               frequency: 90.4,  city: 'Medan', genre: 'pop',           band: Band.fm),
  LocalStation(name: 'Radio Mix FM',               frequency: 90.8,  city: 'Medan', genre: 'pop',           band: Band.fm),
  LocalStation(name: 'M Radio',                    frequency: 91.6,  city: 'Medan', genre: 'pop',           band: Band.fm),
  // TODO: add 91.6+ MHz when verified
  LocalStation(name: 'Radio Bethany',              frequency: 900,   city: 'Medan', genre: 'religious',     band: Band.am),
];

// ── MASTER LIST ───────────────────────────────────────────────────────────────
// To add a new city: create a _cityName const list above and spread it here.
const List<LocalStation> allStations = [
  ..._jakarta,
  ..._surabaya,
  ..._semarang,
  ..._bandung,
  ..._yogyakarta,
  ..._medan,
];

// ── CITY COORDINATES ─────────────────────────────────────────────────────────
const Map<String, ({double lat, double lng})> cityCoordinates = {
  'Jakarta':    (lat: -6.2088, lng: 106.8456),
  'Surabaya':   (lat: -7.2575, lng: 112.7521),
  'Semarang':   (lat: -6.9666, lng: 110.4196),
  'Bandung':    (lat: -6.9175, lng: 107.6191),
  'Yogyakarta': (lat: -7.7956, lng: 110.3695),
  'Medan':      (lat:  3.5952, lng:  98.6722),
  // TODO: add when verified — Makassar, Bali, Solo, Malang
};
