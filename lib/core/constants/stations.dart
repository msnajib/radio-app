// Hardcoded real frequencies for popular Indonesian stations.
// Stations without a known real frequency are omitted (search/list only).
// Format: 'station_name_key': frequency_in_mhz (FM) or frequency_in_khz (AM)

abstract final class KnownFMStations {
  static const Map<String, double> frequencies = {
    'Prambors FM':    102.2,
    'Gen FM':         98.7,
    'Elshinta FM':    90.0,
    'Hard Rock FM':   87.6,
    'Trax FM':        101.4,
    'Delta FM':       99.1,
    'KISS FM':        97.4,
    'Motion Radio':   97.5,
    'Oz Radio':       103.1,
    'BBS Radio':      95.2,
    'MNC Trijaya FM': 104.7,
    'Suara Surabaya': 100.0,
    'Female Radio':   94.3,
    'V Radio':        95.1,
    'Pop FM':         95.6,
    'Brava Radio':    100.8,
    'Smart FM':       95.9,
    'Radio Sonora':   92.0,
    'Retjo Buntung':  99.4,
    'Radio Gajahmada':105.3,
  };
}

abstract final class KnownAMStations {
  static const Map<String, int> frequencies = {
    'Elshinta AM':  720,
    'RRI Pro 1':    630,
    'RRI Pro 2':    900,
    'RRI Pro 3':   1080,
    'Radio Suara Surabaya AM': 1350,
  };
}
