import 'dart:async' show unawaited;
import 'dart:developer' as dev;
import 'dart:isolate';

import '../../core/constants/manual_overrides.dart';
import '../../core/constants/station_aliases.dart';
import '../../core/constants/stations.dart';
import '../datasources/radio_browser_api.dart';
import '../models/match_result.dart';
import '../models/radio_browser_station.dart';
import '../models/station.dart';

// ── Top-level helpers — accessible from spawned isolate ───────────────────────

// Pre-compiled once per isolate; avoids recompilation on every _normText call.
final _reKeywords = RegExp(r'\b(fm|am|radio|stream|online|indonesia)\b');
final _reCities = RegExp(
  r'\b(jakarta|surabaya|semarang|bandung|yogyakarta|jogja|yogya|medan)\b',
);
final _reNonAlpha = RegExp(r'[^a-z0-9 ]');
final _reSpaces = RegExp(r'\s+');
final _reAliasStrip = RegExp(r'\b(fm|am|radio)\b');

const _kKnownCities = [
  'jakarta', 'surabaya', 'semarang', 'bandung',
  'yogyakarta', 'jogja', 'yogya', 'medan',
];

String _normText(String v) => v
    .toLowerCase()
    .replaceAll(_reKeywords, ' ')
    .replaceAll(_reCities, ' ')
    .replaceAll(_reNonAlpha, ' ')
    .replaceAll(_reSpaces, ' ')
    .trim();

List<String> _bigrams(String s) =>
    List.generate(s.length - 1, (i) => s.substring(i, i + 2));

double _dice(String a, String b) {
  if (a.isEmpty || b.isEmpty) return 0.0;
  if (a == b) return 1.0;
  if (a.length < 2 || b.length < 2) return 0.0;
  final ba = _bigrams(a);
  final bb = _bigrams(b).toList();
  int inter = 0;
  for (final bg in ba) {
    final idx = bb.indexOf(bg);
    if (idx != -1) {
      inter++;
      bb.removeAt(idx);
    }
  }
  return (2.0 * inter) / (ba.length + bb.length + inter - inter);
}

// Scores one candidate (serialized as Map) against local station fields.
// All strings are already lowercased/normalized where noted.
double _scorePrimitive(
  String localNameNorm, // pre-normalized
  String localCity, // pre-normalized (yogya→yogyakarta, etc.)
  List<String> localAliases, // pre-lowercased alias strings
  Map<String, Object?> c, // serialized RadioBrowserStation
) {
  double score = 0;

  final apiName = (c['name'] as String?) ?? '';
  final apiNameNorm = _normText(apiName);
  final apiTextNorm = _normText([
    apiName,
    (c['tags'] as String?) ?? '',
    (c['state'] as String?) ?? '',
    (c['country'] as String?) ?? '',
    (c['homepage'] as String?) ?? '',
    (c['url'] as String?) ?? '',
  ].join(' '));
  final apiTextRaw = [
    apiName,
    (c['tags'] as String?) ?? '',
    (c['state'] as String?) ?? '',
    (c['country'] as String?) ?? '',
  ].join(' ').toLowerCase();

  // Dice bigrams on normalized names (0–45)
  score += _dice(localNameNorm, apiNameNorm) * 45;

  // Alias bonus (+20)
  for (final alias in localAliases) {
    if (apiTextNorm.contains(alias)) {
      score += 20;
      break;
    }
  }

  // City match via raw text (+25 or -25)
  if (localCity.isNotEmpty) {
    bool matched = apiTextRaw.contains(localCity);
    if (localCity == 'yogyakarta') {
      matched = matched ||
          apiTextRaw.contains('jogja') ||
          apiTextRaw.contains('yogya');
    }
    if (matched) {
      score += 25;
    } else {
      for (final other in _kKnownCities) {
        final norm =
            (other == 'jogja' || other == 'yogya') ? 'yogyakarta' : other;
        if (norm != localCity && apiTextRaw.contains(other)) {
          score -= 25;
          break;
        }
      }
    }
  }

  // Country Indonesia (+10)
  if (((c['countryCode'] as String?) ?? '').toUpperCase() == 'ID') score += 10;

  // Stream health (+10 active / -20 dead)
  if ((c['lastCheckOk'] as int?) == 1) {
    score += 10;
  } else {
    score -= 20;
  }

  // Bitrate (+5 if >= 64 kbps)
  if (((c['bitrate'] as int?) ?? 0) >= 64) score += 5;

  // Missing playable URL (-40)
  final url = c['url'] as String?;
  if (url == null || url.isEmpty) score -= 40;

  return score.clamp(0.0, 100.0);
}

// Entry point for Isolate.run — must be top-level.
({int bestIndex, double bestScore}) _runScoringIsolate((
  String localNameNorm,
  String localCity,
  List<String> localAliases,
  List<Map<String, Object?>> candidates,
) args) {
  final (localNameNorm, localCity, localAliases, candidates) = args;
  int bestIndex = -1;
  double bestScore = 0;
  for (int i = 0; i < candidates.length; i++) {
    final s = _scorePrimitive(
      localNameNorm,
      localCity,
      localAliases,
      candidates[i],
    );
    if (s > bestScore) {
      bestScore = s;
      bestIndex = i;
    }
  }
  return (bestIndex: bestIndex, bestScore: bestScore);
}

// ── Cache ──────────────────────────────────────────────────────────────────────

class _CacheEntry {
  final MatchResult result;
  final DateTime expires;
  _CacheEntry(this.result, this.expires);
  bool get isValid => DateTime.now().isBefore(expires);
}

// ── Repository ─────────────────────────────────────────────────────────────────

class RadioBrowserRepository {
  final RadioBrowserApi _api;
  RadioBrowserRepository({RadioBrowserApi? api})
    : _api = api ?? RadioBrowserApi();

  Future<List<RadioBrowserStation>>? _apiFetch;
  final _cache = <String, _CacheEntry>{};

  // ── Public API ───────────────────────────────────────────────────────────────

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

  // Core matching entry point.
  Future<MatchResult> matchStation(Station local) async {
    final cacheKey = _cacheKey(local);
    final cached = _cache[cacheKey];
    if (cached != null && cached.isValid) {
      dev.log(
        '[Match] cache hit "$cacheKey" score=${cached.result.score}',
        name: 'Match',
      );
      return cached.result;
    }

    // Step 1 — Manual override
    final manualUuid = kManualOverrides[_overrideKey(local)];
    if (manualUuid != null) {
      final api = await _findByUuid(manualUuid);
      if (api != null && api.isStreamHealthy) {
        final result = MatchResult(
          localStation: local,
          apiStation: _toStation(api, local),
          score: 100,
          strength: SignalStrength.strong,
          source: 'manual',
        );
        _cache[cacheKey] = _CacheEntry(result, _ttl(const Duration(days: 7)));
        dev.log(
          '[Match] manual → "${api.name}" uuid=$manualUuid',
          name: 'Match',
        );
        return result;
      }
    }

    // Step 2 — Auto matching via background isolate
    final apiStations = await _getApiStations();

    // Pre-filter: only healthy streams with a valid URL reduce ~3000 → ~800.
    final candidates = apiStations
        .where((s) => s.lastCheckOk == 1 && s.playableUrl != null)
        .toList();

    dev.log(
      '[Match] scoring ${candidates.length} candidates for "${local.name}"',
      name: 'Match',
    );

    final localNameNorm = _normText(local.name);
    final localCity = _normalizeCity(local.city ?? '');
    final localAliases = _getAliases(local.name);
    final serialized = candidates.map(_serializeStation).toList();

    // Off-load CPU-heavy loop to a background isolate — prevents ANR.
    final scored = await Isolate.run(
      () => _runScoringIsolate((
        localNameNorm,
        localCity,
        localAliases,
        serialized,
      )),
    );

    final bestScore = scored.bestScore;
    final best =
        scored.bestIndex >= 0 ? candidates[scored.bestIndex] : null;

    dev.log(
      '[Match] best="${best?.name}" score=${bestScore.round()} for "${local.name}"',
      name: 'Match',
    );

    final strength = bestScore >= 80
        ? SignalStrength.strong
        : bestScore >= 65
        ? SignalStrength.weak
        : SignalStrength.none;

    final result = MatchResult(
      localStation: local,
      apiStation:
          strength != SignalStrength.none && best != null
              ? _toStation(best, local)
              : null,
      score: bestScore.round(),
      strength: strength,
      source: 'auto',
    );
    final ttl = strength == SignalStrength.none
        ? const Duration(hours: 12)
        : const Duration(days: 1);
    _cache[cacheKey] = _CacheEntry(result, _ttl(ttl));
    return result;
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  // Full name — used for session cache (precise).
  String _cacheKey(Station local) {
    final city = (local.city ?? 'unknown').toLowerCase();
    final freq =
        local.fmFrequency?.toStringAsFixed(1) ??
        local.amFrequency?.toString() ??
        '0';
    return '$city:$freq:${local.name.toLowerCase()}';
  }

  // Strips FM/AM/Radio keywords but keeps city names — matches kManualOverrides.
  String _overrideKey(Station local) {
    final city = (local.city ?? 'unknown').toLowerCase();
    final freq =
        local.fmFrequency?.toStringAsFixed(1) ??
        local.amFrequency?.toString() ??
        '0';
    final name = local.name
        .toLowerCase()
        .replaceAll(_reAliasStrip, '')
        .replaceAll(_reNonAlpha, ' ')
        .replaceAll(_reSpaces, ' ')
        .trim();
    return '$city:$freq:$name';
  }

  String _normalizeCity(String city) {
    final c = city.toLowerCase().trim();
    if (c == 'jogja' || c == 'yogya') return 'yogyakarta';
    return c;
  }

  List<String> _getAliases(String localName) {
    final key1 = localName.toLowerCase();
    final key2 = key1
        .replaceAll(_reAliasStrip, '')
        .replaceAll(_reSpaces, ' ')
        .trim();
    final aliases = kStationAliases[key1] ?? kStationAliases[key2];
    return aliases?.map((a) => a.toLowerCase()).toList() ?? [];
  }

  Map<String, Object?> _serializeStation(RadioBrowserStation s) => {
    'name': s.name,
    'tags': s.tags,
    'state': s.state,
    'country': s.country,
    'homepage': s.homepage,
    'url': s.playableUrl,
    'countryCode': s.countryCode,
    'lastCheckOk': s.lastCheckOk,
    'bitrate': s.bitrate,
  };

  DateTime _ttl(Duration d) => DateTime.now().add(d);

  Future<RadioBrowserStation?> _findByUuid(String uuid) async {
    try {
      return (await _api.searchByUuid(uuid)).firstOrNull;
    } catch (_) {
      return null;
    }
  }

  Future<List<RadioBrowserStation>> _getApiStations() {
    _apiFetch ??= _api.fetchByCountry('indonesia').catchError((e) {
      _apiFetch = null;
      return <RadioBrowserStation>[];
    });
    return _apiFetch!;
  }

  Station _toStation(RadioBrowserStation api, Station local) {
    return local.copyWith(streamUrl: api.playableUrl ?? '');
  }

  Station _localToStation(LocalStation local) => Station(
    id: 'local_${local.city.toLowerCase()}_${local.frequency}',
    name: local.name,
    streamUrl: '',
    fmFrequency: local.fmFrequency,
    amFrequency: local.amFrequency,
    city: local.city,
  );

  // ── Dial navigation helpers ──────────────────────────────────────────────────

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
