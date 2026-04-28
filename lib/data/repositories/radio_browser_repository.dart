import 'dart:async' show unawaited;

import '../../core/constants/stations.dart';
import '../../core/utils/station_frequency_parser.dart';
import '../datasources/radio_browser_api.dart';
import '../models/station.dart';

class RadioBrowserRepository {
  final RadioBrowserApi _api;
  RadioBrowserRepository({RadioBrowserApi? api})
      : _api = api ?? RadioBrowserApi();

  Future<List<Station>>? _apiFetch;

  // Returns hardcoded stations, optionally filtered by city (null = all cities).
  // Instant — no API call. Use this for dial population.
  List<Station> getDialStations({String? city}) {
    final source = city != null
        ? allStations.where((s) => s.city == city)
        : allStations;
    return source.map(_localToStation).toList();
  }

  // Same as getDialStations but async — also warms the API cache in background.
  Future<List<Station>> getIndonesianStations({String? city}) async {
    unawaited(_getApiStations()); // warm cache without blocking
    return getDialStations(city: city);
  }

  // Resolves a playable stream URL for a station.
  // 1. Frequency match against cached API batch (most reliable).
  // 2. Name match against cached API batch.
  // 3. Fallback: search API by station name.
  Future<String?> resolveStreamUrl(Station station) async {
    final apiStations = await _getApiStations();

    final byFreq = _findByFrequency(station, apiStations);
    if (byFreq != null) return byFreq.streamUrl;

    final byName = _findBestMatch(station.name, apiStations);
    if (byName != null) return byName.streamUrl;

    try {
      final results = await _api.search(station.name);
      final byFreqSearch = _findByFrequency(station, results);
      if (byFreqSearch != null) return byFreqSearch.streamUrl;
      return _findBestMatch(station.name, results)?.streamUrl;
    } catch (_) {
      return null;
    }
  }

  // Matches an API station by parsing the frequency embedded in its name.
  // FM tolerance: ±0.15 MHz (handles "101" matching 101.0).
  // AM tolerance: ±10 kHz.
  Station? _findByFrequency(Station target, List<Station> candidates) {
    if (target.hasFMFrequency) {
      final targetFreq = target.fmFrequency!;
      Station? best;
      double bestDist = 0.16;
      for (final s in candidates) {
        final parsed = parseFrequencyFromName(s.name);
        if (parsed.fm != null) {
          final dist = (parsed.fm! - targetFreq).abs();
          if (dist < bestDist) {
            bestDist = dist;
            best = s;
          }
        }
      }
      return best;
    }
    if (target.hasAMFrequency) {
      final targetFreq = target.amFrequency!;
      for (final s in candidates) {
        final parsed = parseFrequencyFromName(s.name);
        if (parsed.am != null && (parsed.am! - targetFreq).abs() <= 10) {
          return s;
        }
      }
    }
    return null;
  }

  // Search for stations via API (used by search overlay).
  Future<List<Station>> search(String query) async {
    return _api.search(query);
  }

  // Returns only FM stations, sorted by frequency.
  List<Station> fmStationsOnDial(List<Station> all) {
    return all.where((s) => s.hasFMFrequency).toList()
      ..sort((a, b) => a.fmFrequency!.compareTo(b.fmFrequency!));
  }

  // Returns only AM stations, sorted by frequency.
  List<Station> amStationsOnDial(List<Station> all) {
    return all.where((s) => s.hasAMFrequency).toList()
      ..sort((a, b) => a.amFrequency!.compareTo(b.amFrequency!));
  }

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
    return (prev: prev ?? sorted.last, next: next ?? sorted.first);
  }

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
    return (prev: prev ?? sorted.last, next: next ?? sorted.first);
  }

  Future<List<Station>> _getApiStations() {
    _apiFetch ??= _api.fetchByCountry('indonesia').catchError((e) {
      _apiFetch = null; // allow retry on next call if fetch failed
      return <Station>[];
    });
    return _apiFetch!;
  }

  // Finds the API station whose name best matches the target.
  Station? _findBestMatch(String targetName, List<Station> candidates) {
    final target = _normalize(targetName);
    if (target.isEmpty) return null;

    for (final s in candidates) {
      if (_normalize(s.name) == target) return s;
    }

    if (target.length >= 4) {
      for (final s in candidates) {
        final n = _normalize(s.name);
        if (n.length >= 4 && (n.contains(target) || target.contains(n))) {
          return s;
        }
      }
    }

    return null;
  }

  String _normalize(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'\b(fm|am|radio)\b'), '')
        .replaceAll(RegExp(r'[^a-z0-9]'), ' ')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  Station _localToStation(LocalStation local) => Station(
        id: 'local_${local.city.toLowerCase()}_${local.frequency}',
        name: local.name,
        streamUrl: '',
        fmFrequency: local.fmFrequency,
        amFrequency: local.amFrequency,
      );

  void dispose() => _api.dispose();
}
