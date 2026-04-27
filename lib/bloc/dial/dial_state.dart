import 'package:equatable/equatable.dart';
import '../../core/constants/frequencies.dart';
import '../../data/models/station.dart';

class DialState extends Equatable {
  /// Normalized position 0.0 (min freq) → 1.0 (max freq).
  final double position;
  final Band band;
  final bool isSnapping;

  /// Stations available on the current band (populated from RadioBloc via listener).
  final List<Station> stations;

  /// Non-null while the needle is sitting on a station (set on snap, cleared when
  /// the user drags away or switches band).
  final Station? snappedStation;

  const DialState({
    this.position = 0.0,
    this.band = Band.fm,
    this.isSnapping = false,
    this.stations = const [],
    this.snappedStation,
  });

  DialState copyWith({
    double? position,
    Band? band,
    bool? isSnapping,
    List<Station>? stations,
    Station? snappedStation,
    bool clearSnappedStation = false,
  }) {
    return DialState(
      position: position ?? this.position,
      band: band ?? this.band,
      isSnapping: isSnapping ?? this.isSnapping,
      stations: stations ?? this.stations,
      snappedStation:
          clearSnappedStation ? null : (snappedStation ?? this.snappedStation),
    );
  }

  @override
  List<Object?> get props =>
      [position, band, isSnapping, stations, snappedStation];
}
