import 'dart:async' show unawaited;
import 'dart:developer' as dev;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/frequencies.dart';
import '../../core/utils/frequency_mapper.dart';
import '../../data/datasources/hive_datasource.dart';
import '../../data/models/station.dart';
import 'dial_event.dart';
import 'dial_state.dart';

// Snap threshold: 1.5 FM steps (0.15 MHz) or 2 AM steps (20 kHz).
const double _kFMSnapThreshold = 0.15;
const int _kAMSnapThreshold = 20;

class DialBloc extends Bloc<DialEvent, DialState> {
  final HiveDatasource _datasource;

  DialBloc({required HiveDatasource datasource})
      : _datasource = datasource,
        super(DialState(
          position: datasource.getDialPosition(),
          band: datasource.getDialBand(),
        )) {
    on<DialDragged>(_onDragged);
    on<DialReleased>(_onReleased);
    on<DialJumpedToPosition>(_onJumped);
    on<DialBandSwitched>(_onBandSwitched);
    on<DialSnapped>(_onSnapped);
    on<DialStationsUpdated>(_onStationsUpdated);
  }

  void _onDragged(DialDragged event, Emitter<DialState> emit) {
    double newPos = state.position + event.delta;
    newPos = newPos % 1.0;
    if (newPos < 0) newPos += 1.0;
    // No snap while dragging — avoids the "sticky resistance" when passing a station.
    // Snap only fires on release so the dial moves freely under the finger.
    emit(state.copyWith(
      position: newPos,
      isSnapping: false,
      clearSnappedStation: true,
    ));
  }

  void _onReleased(DialReleased event, Emitter<DialState> emit) {
    double newPos = state.position + event.velocityDelta;
    newPos = newPos % 1.0;
    if (newPos < 0) newPos += 1.0;
    final snap = _checkSnap(newPos);
    final savedPos = snap?.position ?? newPos;
    if (snap != null) {
      dev.log('[XYZ][DialBloc] SNAP → "${snap.station.name}" @ ${snap.station.fmFrequency ?? snap.station.amFrequency}', name: 'Dial');
      emit(state.copyWith(
        position: snap.position,
        isSnapping: true,
        snappedStation: snap.station,
      ));
    } else {
      dev.log('[XYZ][DialBloc] released @ $newPos — no snap (${state.stations.length} stations loaded)', name: 'Dial');
      emit(state.copyWith(position: newPos, isSnapping: false));
    }
    unawaited(_datasource.saveDialPosition(savedPos));
  }

  void _onJumped(DialJumpedToPosition event, Emitter<DialState> emit) {
    final pos = event.position.clamp(0.0, 1.0);
    final snap = _checkSnap(pos);
    final savedPos = snap?.position ?? pos;
    if (snap != null) {
      emit(state.copyWith(
        position: snap.position,
        isSnapping: true,
        snappedStation: snap.station,
      ));
    } else {
      emit(state.copyWith(position: pos, isSnapping: false, clearSnappedStation: true));
    }
    unawaited(_datasource.saveDialPosition(savedPos));
  }

  void _onBandSwitched(DialBandSwitched event, Emitter<DialState> emit) {
    emit(DialState(band: event.band, stations: state.stations));
    unawaited(_datasource.saveDialBand(event.band));
  }

  void _onSnapped(DialSnapped event, Emitter<DialState> emit) {
    emit(state.copyWith(position: event.position, isSnapping: true));
  }

  void _onStationsUpdated(DialStationsUpdated event, Emitter<DialState> emit) {
    dev.log('[XYZ][DialBloc] stations updated: ${event.stations.length} stations on dial', name: 'Dial');
    emit(state.copyWith(stations: event.stations));
    final snap = _checkSnap(state.position);
    if (snap != null) {
      dev.log('[XYZ][DialBloc] on-load SNAP → "${snap.station.name}"', name: 'Dial');
      emit(state.copyWith(
        position: snap.position,
        isSnapping: true,
        snappedStation: snap.station,
      ));
      unawaited(_datasource.saveDialPosition(snap.position));
    }
  }

  // Returns snap target if current freq is within threshold of a known station.
  ({double position, Station station})? _checkSnap(double pos) {
    if (state.stations.isEmpty) return null;

    if (state.band == Band.fm) {
      final freq = FrequencyMapper.positionToFM(pos);
      Station? nearest;
      double minDist = double.infinity;
      for (final s in state.stations) {
        if (!s.hasFMFrequency) continue;
        final dist = (s.fmFrequency! - freq).abs();
        if (dist <= _kFMSnapThreshold && dist < minDist) {
          minDist = dist;
          nearest = s;
        }
      }
      if (nearest != null) {
        return (
          position: FrequencyMapper.fmToPosition(nearest.fmFrequency!),
          station: nearest,
        );
      }
    } else {
      final freq = FrequencyMapper.positionToAM(pos);
      Station? nearest;
      int minDist = _kAMSnapThreshold + 1;
      for (final s in state.stations) {
        if (!s.hasAMFrequency) continue;
        final dist = (s.amFrequency! - freq).abs();
        if (dist <= _kAMSnapThreshold && dist < minDist) {
          minDist = dist;
          nearest = s;
        }
      }
      if (nearest != null) {
        return (
          position: FrequencyMapper.amToPosition(nearest.amFrequency!),
          station: nearest,
        );
      }
    }
    return null;
  }
}
