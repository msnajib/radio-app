import '../../core/constants/stations.dart';
import '../../core/utils/station_frequency_parser.dart';
import '../datasources/radio_browser_api.dart';
import '../models/station.dart';

class RadioBrowserRepository {
  final RadioBrowserApi _api;

  RadioBrowserRepository({RadioBrowserApi? api})
      : _api = api ?? RadioBrowserApi();

  Future<List<Station>> getIndonesianStations() async {
    final stations = await _api.fetchByCountry('indonesia');
    return _assignFrequencies(stations);
  }

  Future<List<Station>> search(String query) async {
    final stations = await _api.search(query);
    return _assignFrequencies(stations);
  }

  // Assigns real FM/AM frequencies to stations.
  // Priority: frequency embedded in station name (from API) → hardcoded fallback.
  List<Station> _assignFrequencies(List<Station> stations) {
    return stations.map((station) {
      final name = station.name.trim();

      // 1. Parse frequency directly from station name (SSOT from API)
      final parsed = parseFrequencyFromName(name);
      if (parsed.fm != null) return station.copyWith(fmFrequency: parsed.fm);
      if (parsed.am != null) return station.copyWith(amFrequency: parsed.am);

      // 2. Fallback: hardcoded map for stations whose names omit the frequency
      final nameLower = name.toLowerCase();
      for (final entry in KnownFMStations.frequencies.entries) {
        final key = entry.key.toLowerCase();
        if (nameLower.contains(key) || key.contains(nameLower)) {
          return station.copyWith(fmFrequency: entry.value);
        }
      }
      for (final entry in KnownAMStations.frequencies.entries) {
        final key = entry.key.toLowerCase();
        if (nameLower.contains(key) || key.contains(nameLower)) {
          return station.copyWith(amFrequency: entry.value);
        }
      }

      return station;
    }).toList();
  }

  // Returns only stations with a known real FM frequency, sorted by frequency.
  List<Station> fmStationsOnDial(List<Station> all) {
    return all
        .where((s) => s.hasFMFrequency)
        .toList()
      ..sort((a, b) => a.fmFrequency!.compareTo(b.fmFrequency!));
  }

  // Returns only stations with a known real AM frequency, sorted by frequency.
  List<Station> amStationsOnDial(List<Station> all) {
    return all
        .where((s) => s.hasAMFrequency)
        .toList()
      ..sort((a, b) => a.amFrequency!.compareTo(b.amFrequency!));
  }

  // Finds the nearest station to a given FM frequency within snap threshold.
  Station? snapFM(List<Station> stations, double freqMHz, double threshold) {
    Station? nearest;
    double minDist = double.infinity;
    for (final s in stations) {
      if (!s.hasFMFrequency) continue;
      final dist = (s.fmFrequency! - freqMHz).abs();
      if (dist < threshold && dist < minDist) {
        minDist = dist;
        nearest = s;
      }
    }
    return nearest;
  }

  // Finds the nearest station to a given AM frequency within snap threshold.
  Station? snapAM(List<Station> stations, int freqKHz, int threshold) {
    Station? nearest;
    int minDist = threshold + 1;
    for (final s in stations) {
      if (!s.hasAMFrequency) continue;
      final dist = (s.amFrequency! - freqKHz).abs();
      if (dist < threshold && dist < minDist) {
        minDist = dist;
        nearest = s;
      }
    }
    return nearest;
  }

  // Stations adjacent to a given FM frequency (for prev/next navigation).
  ({Station? prev, Station? next}) adjacentFM(
    List<Station> stations,
    double freqMHz,
  ) {
    final sorted = fmStationsOnDial(stations);
    if (sorted.isEmpty) return (prev: null, next: null);
    Station? prev, next;
    for (final s in sorted) {
      if (s.fmFrequency! < freqMHz) prev = s;
      if (s.fmFrequency! > freqMHz && next == null) next = s;
    }
    // Wrap around at edges
    return (prev: prev ?? sorted.last, next: next ?? sorted.first);
  }

  // Stations adjacent to a given AM frequency (for prev/next navigation).
  ({Station? prev, Station? next}) adjacentAM(
    List<Station> stations,
    int freqKHz,
  ) {
    final sorted = amStationsOnDial(stations);
    if (sorted.isEmpty) return (prev: null, next: null);
    Station? prev, next;
    for (final s in sorted) {
      if (s.amFrequency! < freqKHz) prev = s;
      if (s.amFrequency! > freqKHz && next == null) next = s;
    }
    // Wrap around at edges
    return (prev: prev ?? sorted.last, next: next ?? sorted.first);
  }

  void dispose() => _api.dispose();
}
