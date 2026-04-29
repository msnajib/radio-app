import 'package:firebase_analytics/firebase_analytics.dart';
import '../../data/models/favorite.dart';
import '../../data/models/station.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  Future<void> logStationPlay(Station station) async {
    await _analytics.logEvent(
      name: 'station_play',
      parameters: {
        'station_name': station.name,
        'frequency': station.hasFMFrequency
            ? '${station.fmFrequency} FM'
            : station.hasAMFrequency
                ? '${station.amFrequency} AM'
                : 'unknown',
        'genre': station.tags.isNotEmpty ? station.tags.first : 'unknown',
        'city': 'unknown',
      },
    );
  }

  Future<void> logStationFavorite(Station station, {required bool added}) async {
    await _analytics.logEvent(
      name: 'station_favorite',
      parameters: {
        'station_name': station.name,
        'frequency': station.hasFMFrequency
            ? '${station.fmFrequency} FM'
            : station.hasAMFrequency
                ? '${station.amFrequency} AM'
                : 'unknown',
        'genre': station.tags.isNotEmpty ? station.tags.first : 'unknown',
        'action': added ? 'add' : 'remove',
      },
    );
  }

  Future<void> logBandSwitch(String band) async {
    await _analytics.logEvent(
      name: 'band_switch',
      parameters: {'band': band},
    );
  }

  Future<void> logDialTune(double frequency, String band) async {
    await _analytics.logEvent(
      name: 'dial_tune',
      parameters: {
        'frequency': frequency,
        'band': band,
      },
    );
  }

  Future<void> logStationFavoriteRemoved(Favorite favorite) async {
    await _analytics.logEvent(
      name: 'station_favorite',
      parameters: {
        'station_name': favorite.stationName,
        'frequency': favorite.fmFrequency != null
            ? '${favorite.fmFrequency} FM'
            : favorite.amFrequency != null
                ? '${favorite.amFrequency} AM'
                : 'unknown',
        'action': 'remove',
      },
    );
  }

  Future<void> logSleepTimerSet(int minutes) async {
    await _analytics.logEvent(
      name: 'sleep_timer_set',
      parameters: {'duration_minutes': minutes},
    );
  }
}
