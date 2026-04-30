import 'dart:async' show unawaited;
import 'dart:developer' as dev;

import '../../core/constants/manual_overrides.dart';
import '../../core/constants/station_aliases.dart';
import '../../core/constants/stations.dart';
import '../datasources/radio_browser_api.dart';
import '../models/match_result.dart';
import '../models/station.dart';

// ── Province/state names from Radio Browser for each local city ────────────
const _kCityProvinces = <String, List<String>>{
  'jakarta':     ['dki jakarta', 'jakarta', 'banten'],
  'surabaya':    ['jawa timur', 'east java', 'java timur'],
  'bandung':     ['jawa barat', 'west java', 'java barat'],
  'semarang':    ['jawa tengah', 'central java', 'java tengah'],
  'yogyakarta':  ['daerah istimewa yogyakarta', 'yogyakarta', 'di yogyakarta'],
  'medan':       ['sumatera utara', 'north sumatra', 'sumatera utara'],
  'makassar':    ['sulawesi selatan', 'south sulawesi'],
  'bali':        ['bali'],
  'malang':      ['jawa timur', 'east java'],
  'solo':        ['jawa tengah', 'central java'],
};

class _CacheEntry {
  final MatchResult result;
  final DateTime expires;
  _CacheEntry(this.result, this.expires);
  bool get isValid => DateTime.now().isBefore(expires);
}

class RadioBrowserRepository {
  final RadioBrowserApi _api;
  RadioBrowserRepository({RadioBrowserApi? api})
      : _api = api ?? RadioBrowserApi();

  Future<List<Station>>? _apiFetch;
  final _cache = <String, _CacheEntry>{};

  // ── Public API ─────────────────────────────────────────────────────────────

  List<Station> getDialStations({String? city}) {
    final source = city != null
        ? allStations.where((s) => s.city == city)
        : allStations;
    return source.map(_localToStation).toList();
  }

  Future<List<Station>> getIndonesianStations({String? city}) async {
    unawaited(_getApiStations());
    return getDialStations(city: city);
  }

  Future<List<Station>> search(String query) => _api.search(query);

  // Core matching entry point. Returns a MatchResult with signal strength.
  Future<MatchResult> matchStation(Station local) async {
    final cacheKey = _cacheKey(local);
    final cached = _cache[cacheKey];
    if (cached != null && cached.isValid) {
      dev.log('[Match] cache hit for "$cacheKey" score=${cached.result.score}', name: 'Match');
      return cached.result;
    }

    // Step 1 — Manual override
    final overrideKey = _overrideKey(local);
    final manualUuid = kManualOverrides[overrideKey];
    if (manualUuid != null) {
      final api = await _findByUuid(manualUuid);
      if (api != null) {
        final result = MatchResult(
          localStation: local,
          apiStation: api,
          score: 100,
          strength: SignalStrength.strong,
          source: 'manual',
        );
        _cache[cacheKey] = _CacheEntry(result, _ttl(const Duration(days: 7)));
        dev.log('[Match] manual override → "${api.name}" uuid=$manualUuid', name: 'Match');
        return result;
      }
    }

    // Step 2 — Auto matching with scoring
    final apiStations = await _getApiStations();
    final scored = <({Station api, int score})>[];
    for (final api in apiStations) {
      final s = _score(local, api);
      if (s > 0) scored.add((api: api, score: s));
    }
    scored.sort((a, b) => b.score.compareTo(a.score));

    if (scored.isEmpty) {
      final result = MatchResult(
        localStation: local,
        apiStation: null,
        score: 0,
        strength: SignalStrength.none,
        source: 'none',
      );
      _cache[cacheKey] = _CacheEntry(result, _ttl(const Duration(hours: 12)));
      dev.log('[Match] no candidates for "${local.name}"', name: 'Match');
      return result;
    }

    final best = scored.first;
    dev.log(
      '[Match] best="${best.api.name}" score=${best.score} for "${local.name}"',
      name: 'Match',
    );

    final strength = best.score >= 80
        ? SignalStrength.strong
        : best.score >= 65
            ? SignalStrength.weak
            : SignalStrength.none;

    final result = MatchResult(
      localStation: local,
      apiStation: strength != SignalStrength.none ? best.api : null,
      score: best.score,
      strength: strength,
      source: 'auto',
    );
    final ttl = strength == SignalStrength.none
        ? const Duration(hours: 12)
        : const Duration(days: 1);
    _cache[cacheKey] = _CacheEntry(result, _ttl(ttl));
    return result;
  }

  // ── Scoring ────────────────────────────────────────────────────────────────

  int _score(Station local, Station api) {
    double score = 0;

    // Name similarity: 0-45
    final sim = _nameSimilarity(local.name, api.name);
    score += sim * 45;

    // Alias bonus: +20
    if (_hasAliasMatch(local.name, api.name)) score += 20;

    // City/province match: +25 or -25
    final cityScore = _cityScore(local, api);
    score += cityScore;

    // Country Indonesia: +10
    if (_isIndonesia(api)) score += 10;

    // Active stream: +10 or -20
    if (api.lastCheckok) {
      score += 10;
    } else {
      score -= 20;
    }

    // Bitrate bonus: +5 (>=64kbps is reasonable quality)
    if (api.bitrate >= 64) score += 5;

    return score.round().clamp(0, 100);
  }

  // Dice coefficient on normalized word sets. Returns 0.0–1.0.
  double _nameSimilarity(String a, String b) {
    final wordsA = _normalizedWords(a).toSet();
    final wordsB = _normalizedWords(b).toSet();
    if (wordsA.isEmpty || wordsB.isEmpty) return 0.0;
    final intersection = wordsA.intersection(wordsB).length;
    return (2 * intersection) / (wordsA.length + wordsB.length);
  }

  Set<String> _normalizedWords(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'\b(fm|am|radio)\b'), ' ')
        .replaceAll(RegExp(r'[^a-z0-9]'), ' ')
        .split(' ')
        .where((w) => w.length >= 2)
        .toSet();
  }

  bool _hasAliasMatch(String localName, String apiName) {
    final normLocal = _normalizeName(localName);
    final normApi = apiName.toLowerCase();
    final aliases = kStationAliases[normLocal];
    if (aliases == null) return false;
    return aliases.any((alias) => normApi.contains(alias));
  }

  int _cityScore(Station local, Station api) {
    final city = local.city?.toLowerCase();
    if (city == null) return 0;
    final provinces = _kCityProvinces[city];
    if (provinces == null) return 0;
    final apiState = (api.state ?? '').toLowerCase();
    if (apiState.isEmpty) return 0;
    return provinces.any((p) => apiState.contains(p) || p.contains(apiState))
        ? 25
        : -25;
  }

  bool _isIndonesia(Station api) {
    final c = (api.country ?? '').toLowerCase();
    return c.contains('indonesia') || c.contains('id');
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _cacheKey(Station local) {
    final city = (local.city ?? 'unknown').toLowerCase();
    final freq = local.fmFrequency?.toStringAsFixed(1) ??
        local.amFrequency?.toString() ??
        '0';
    return '$city:$freq:${_normalizeName(local.name)}';
  }

  String _overrideKey(Station local) {
    final city = (local.city ?? '').toLowerCase();
    final freq = local.fmFrequency?.toStringAsFixed(1) ??
        local.amFrequency?.toString() ??
        '0';
    return '$city:$freq:${_normalizeName(local.name)}';
  }

  String _normalizeName(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'\b(fm|am|radio)\b'), '')
        .replaceAll(RegExp(r'[^a-z0-9]'), ' ')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  DateTime _ttl(Duration duration) => DateTime.now().add(duration);

  Future<Station?> _findByUuid(String uuid) async {
    try {
      final results = await _api.searchByUuid(uuid);
      return results.firstOrNull;
    } catch (_) {
      return null;
    }
  }

  Future<List<Station>> _getApiStations() {
    _apiFetch ??= _api.fetchByCountry('indonesia').catchError((e) {
      _apiFetch = null;
      return <Station>[];
    });
    return _apiFetch!;
  }

  Station _localToStation(LocalStation local) => Station(
        id: 'local_${local.city.toLowerCase()}_${local.frequency}',
        name: local.name,
        streamUrl: '',
        fmFrequency: local.fmFrequency,
        amFrequency: local.amFrequency,
        city: local.city,
      );

  // ── Dial navigation helpers ────────────────────────────────────────────────

  List<Station> fmStationsOnDial(List<Station> all) =>
      all.where((s) => s.hasFMFrequency).toList()
        ..sort((a, b) => a.fmFrequency!.compareTo(b.fmFrequency!));

  List<Station> amStationsOnDial(List<Station> all) =>
      all.where((s) => s.hasAMFrequency).toList()
        ..sort((a, b) => a.amFrequency!.compareTo(b.amFrequency!));

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

  void dispose() => _api.dispose();
}
