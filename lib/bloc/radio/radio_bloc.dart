import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_radio_player/flutter_radio_player.dart';

import '../../core/constants/frequencies.dart';
import '../../core/utils/frequency_mapper.dart';
import '../../data/models/match_result.dart';
import '../../data/models/station.dart';
import '../../data/repositories/radio_browser_repository.dart';
import 'radio_event.dart';
import 'radio_state.dart';

class RadioBloc extends Bloc<RadioEvent, RadioState> {
  final RadioBrowserRepository _repository;
  final String? _initialCity;
  final FlutterRadioPlayer _player = FlutterRadioPlayer();
  StreamSubscription<bool>? _isPlayingSub;
  Timer? _unmuteFadeTimer;
  int _loadToken = 0;

  RadioBloc({required RadioBrowserRepository repository, String? initialCity})
    : _repository = repository,
      _initialCity = initialCity,
      super(const RadioState()) {
    _isPlayingSub = _player.isPlayingStream.listen(
      (isPlaying) {
        dev.log('[XYZ][RadioBloc] isPlayingStream → $isPlaying', name: 'Radio');
        add(RadioPlayerStatusChanged(isPlaying));
      },
      onError: (e) {
        dev.log('[XYZ][RadioBloc] isPlayingStream error: $e', name: 'Radio');
        add(RadioErrorOccurred(e.toString()));
      },
    );

    on<RadioInitialized>(_onInitialized);
    on<RadioPlayerStatusChanged>(_onPlayerStatus);
    on<RadioStationsLoaded>(_onStationsLoaded);
    on<RadioStationSelected>(_onStationSelected);
    on<RadioPlayPressed>(_onPlay);
    on<RadioPausePressed>(_onPause);
    on<RadioStopPressed>(_onStop);
    on<RadioMuteToggled>(_onMuteToggled);
    on<RadioErrorOccurred>(_onError);
    on<RadioPreviousPressed>(_onPrevious);
    on<RadioNextPressed>(_onNext);
    on<RadioSleepFadeOutPressed>(_onSleepFadeOut);
  }

  Future<void> _onInitialized(
    RadioInitialized event,
    Emitter<RadioState> emit,
  ) async {
    dev.log('[XYZ][RadioBloc] initializing — fetching stations', name: 'Radio');
    try {
      final stations = await _repository.getIndonesianStations(city: _initialCity);
      dev.log(
        '[XYZ][RadioBloc] loaded ${stations.length} stations',
        name: 'Radio',
      );
      emit(state.copyWith(allStations: stations));
    } catch (e) {
      dev.log('[XYZ][RadioBloc] failed to load stations: $e', name: 'Radio');
    }
  }

  void _onPlayerStatus(
    RadioPlayerStatusChanged event,
    Emitter<RadioState> emit,
  ) {
    // Only react to true — confirms stream is playing, update status.
    // false is ignored: HLS emits false between chunks; user actions
    // (pause/stop) update status directly without waiting for the stream.
    if (!event.isPlaying) {
      dev.log(
        '[XYZ][RadioBloc] isPlayingStream false — ignored',
        name: 'Radio',
      );
      return;
    }
    if (state.status != RadioStatus.playing) {
      dev.log(
        '[XYZ][RadioBloc] status: ${state.status} → playing',
        name: 'Radio',
      );
      emit(state.copyWith(status: RadioStatus.playing));
    }
  }

  void _onStationsLoaded(RadioStationsLoaded event, Emitter<RadioState> emit) {
    emit(state.copyWith(allStations: event.stations));
  }

  Future<void> _onStationSelected(
    RadioStationSelected event,
    Emitter<RadioState> emit,
  ) async {
    _unmuteFadeTimer?.cancel();
    _loadToken++;
    final local = event.station;
    emit(state.copyWith(status: RadioStatus.loading, currentStation: local));

    if (local.streamUrl.isEmpty) {
      dev.log('[XYZ][RadioBloc] matching "${local.name}"', name: 'Radio');
      final match = await _repository.matchStation(local);
      dev.log(
        '[XYZ][RadioBloc] match result: score=${match.score} strength=${match.strength} source=${match.source}',
        name: 'Radio',
      );

      if (match.strength == SignalStrength.none) {
        emit(state.copyWith(status: RadioStatus.error, errorMessage: 'Stream tidak tersedia'));
        return;
      }

      final station = match.playableStation;

      if (match.strength == SignalStrength.weak) {
        dev.log('[XYZ][RadioBloc] weak signal → "${station.name}" (score=${match.score})', name: 'Radio');
        emit(state.copyWith(
          status: RadioStatus.weakSignal,
          currentStation: station,
          allStations: _cacheUrl(state.allStations, station),
        ));
        return;
      }

      // strong → auto-play
      emit(state.copyWith(
        currentStation: station,
        allStations: _cacheUrl(state.allStations, station),
      ));
      dev.log('[XYZ][RadioBloc] strong match → "${match.apiStation!.name}" url=${station.streamUrl}', name: 'Radio');
      try {
        await _loadStation(station);
      } catch (e) {
        dev.log('[XYZ][RadioBloc] _loadStation error: $e', name: 'Radio');
        emit(state.copyWith(status: RadioStatus.error, errorMessage: e.toString()));
      }
    } else {
      dev.log('[XYZ][RadioBloc] station already has URL: "${local.name}"', name: 'Radio');
      try {
        await _loadStation(local);
      } catch (e) {
        emit(state.copyWith(status: RadioStatus.error, errorMessage: e.toString()));
      }
    }
  }

  Future<void> _onPlay(RadioPlayPressed event, Emitter<RadioState> emit) async {
    dev.log(
      '[XYZ][RadioBloc] PLAY pressed — status=${state.status} station=${state.currentStation?.name}',
      name: 'Radio',
    );
    if (state.currentStation == null) return;
    if (state.status == RadioStatus.initial ||
        state.status == RadioStatus.stopped ||
        state.status == RadioStatus.error ||
        state.status == RadioStatus.weakSignal) {
      emit(state.copyWith(status: RadioStatus.loading));
      var station = state.currentStation!;
      if (station.streamUrl.isEmpty) {
        final match = await _repository.matchStation(station);
        if (match.apiStation == null) {
          emit(state.copyWith(status: RadioStatus.error, errorMessage: 'Stream tidak tersedia'));
          return;
        }
        station = match.playableStation;
        emit(state.copyWith(
          currentStation: station,
          allStations: _cacheUrl(state.allStations, station),
        ));
      }
      _loadStation(station);
    } else {
      emit(state.copyWith(status: RadioStatus.loading));
      _player.play();
    }
  }

  void _onPause(RadioPausePressed event, Emitter<RadioState> emit) {
    dev.log('[XYZ][RadioBloc] PAUSE pressed', name: 'Radio');
    _player.pause();
    emit(state.copyWith(status: RadioStatus.paused));
  }

  void _onStop(RadioStopPressed event, Emitter<RadioState> emit) {
    dev.log(
      '[XYZ][RadioBloc] STOP — rotated away (cancelling load token=${++_loadToken})',
      name: 'Radio',
    );
    _player.pause();
    emit(
      state.copyWith(status: RadioStatus.stopped, clearCurrentStation: true),
    );
  }

  void _onMuteToggled(RadioMuteToggled event, Emitter<RadioState> emit) {
    final muted = !state.isMuted;
    dev.log('[XYZ][RadioBloc] mute toggled → $muted', name: 'Radio');
    _unmuteFadeTimer?.cancel();
    if (muted) {
      _player.setVolume(0.0);
    } else {
      // Fade in from 0 → 1.0 over 300ms to avoid sudden loudness
      double vol = 0.0;
      _unmuteFadeTimer = Timer.periodic(const Duration(milliseconds: 30), (t) {
        vol = (vol + 0.1).clamp(0.0, 1.0);
        _player.setVolume(vol);
        if (vol >= 1.0) t.cancel();
      });
    }
    emit(state.copyWith(isMuted: muted));
  }

  void _onError(RadioErrorOccurred event, Emitter<RadioState> emit) {
    dev.log('[XYZ][RadioBloc] ERROR: ${event.message}', name: 'Radio');
    emit(
      state.copyWith(status: RadioStatus.error, errorMessage: event.message),
    );
  }

  void _onPrevious(RadioPreviousPressed event, Emitter<RadioState> emit) {
    if (state.allStations.isEmpty) return;
    Station? target;
    final current = state.currentStation;
    if (current != null) {
      if (event.band == Band.fm && current.hasFMFrequency) {
        target = _repository
            .adjacentFM(state.allStations, current.fmFrequency!)
            .prev;
      } else if (event.band == Band.am && current.hasAMFrequency) {
        target = _repository
            .adjacentAM(state.allStations, current.amFrequency!)
            .prev;
      }
    } else {
      // No current station — find nearest from dial position
      if (event.band == Band.fm) {
        final freq = FrequencyMapper.positionToFM(event.dialPosition);
        target = _repository.adjacentFM(state.allStations, freq).prev;
      } else {
        final freq = FrequencyMapper.positionToAM(event.dialPosition);
        target = _repository.adjacentAM(state.allStations, freq).prev;
      }
    }
    if (target == null) return;
    dev.log('[XYZ][RadioBloc] PREV → "${target.name}"', name: 'Radio');
    add(RadioStationSelected(target));
  }

  void _onNext(RadioNextPressed event, Emitter<RadioState> emit) {
    if (state.allStations.isEmpty) return;
    Station? target;
    final current = state.currentStation;
    if (current != null) {
      if (event.band == Band.fm && current.hasFMFrequency) {
        target = _repository
            .adjacentFM(state.allStations, current.fmFrequency!)
            .next;
      } else if (event.band == Band.am && current.hasAMFrequency) {
        target = _repository
            .adjacentAM(state.allStations, current.amFrequency!)
            .next;
      }
    } else {
      // No current station — find nearest from dial position
      if (event.band == Band.fm) {
        final freq = FrequencyMapper.positionToFM(event.dialPosition);
        target = _repository.adjacentFM(state.allStations, freq).next;
      } else {
        final freq = FrequencyMapper.positionToAM(event.dialPosition);
        target = _repository.adjacentAM(state.allStations, freq).next;
      }
    }
    if (target == null) return;
    dev.log('[XYZ][RadioBloc] NEXT → "${target.name}"', name: 'Radio');
    add(RadioStationSelected(target));
  }

  Future<void> _loadStation(Station station) async {
    final token = ++_loadToken;
    dev.log(
      '[XYZ][RadioBloc] ── AUTOPLAY START ── "${station.name}" token=$token',
      name: 'Radio',
    );
    dev.log('[XYZ][RadioBloc] stream url: ${station.streamUrl}', name: 'Radio');
    await _player.initialize([
      RadioSource(url: station.streamUrl, title: station.name),
    ], playWhenReady: true);
    _player.setVolume(state.isMuted ? 0.0 : 1.0);
    if (token != _loadToken) {
      dev.log(
        '[XYZ][RadioBloc] load cancelled (token=$token current=$_loadToken)',
        name: 'Radio',
      );
      await _player.pause();
      return;
    }
    dev.log('[XYZ][RadioBloc] ── AUTOPLAY TRIGGERED ──', name: 'Radio');
  }

  Future<void> _onSleepFadeOut(
    RadioSleepFadeOutPressed event,
    Emitter<RadioState> emit,
  ) async {
    dev.log(
      '[XYZ][RadioBloc] sleep timer expired — fading out over 3s',
      name: 'Radio',
    );
    // Fade vol 1.0 → 0.0 in 10 steps over 3 seconds
    for (int i = 9; i >= 0; i--) {
      await Future.delayed(const Duration(milliseconds: 300));
      _player.setVolume(i / 10.0);
    }
    _player.pause();
    _player.setVolume(1.0); // restore for next play
    emit(state.copyWith(status: RadioStatus.stopped));
    dev.log('[XYZ][RadioBloc] sleep fade out complete', name: 'Radio');
  }

  List<Station> _cacheUrl(List<Station> stations, Station resolved) {
    return stations
        .map((s) => s.id == resolved.id ? resolved : s)
        .toList();
  }

  @override
  Future<void> close() async {
    _unmuteFadeTimer?.cancel();
    await _isPlayingSub?.cancel();
    await _player.dispose();
    return super.close();
  }
}
