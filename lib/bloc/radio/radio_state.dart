import 'package:equatable/equatable.dart';
import '../../data/models/station.dart';

enum RadioStatus { initial, loading, playing, paused, stopped, error }

class RadioState extends Equatable {
  final RadioStatus status;
  final Station? currentStation;
  final List<Station> allStations;
  final String? errorMessage;
  final bool isMuted;

  const RadioState({
    this.status = RadioStatus.initial,
    this.currentStation,
    this.allStations = const [],
    this.errorMessage,
    this.isMuted = false,
  });

  bool get isPlaying => status == RadioStatus.playing;
  bool get isPaused => status == RadioStatus.paused;
  bool get isLoading => status == RadioStatus.loading;

  RadioState copyWith({
    RadioStatus? status,
    Station? currentStation,
    bool clearCurrentStation = false,
    List<Station>? allStations,
    String? errorMessage,
    bool? isMuted,
  }) {
    return RadioState(
      status: status ?? this.status,
      currentStation: clearCurrentStation ? null : (currentStation ?? this.currentStation),
      allStations: allStations ?? this.allStations,
      errorMessage: errorMessage ?? this.errorMessage,
      isMuted: isMuted ?? this.isMuted,
    );
  }

  @override
  List<Object?> get props => [status, currentStation, allStations, errorMessage, isMuted];
}
