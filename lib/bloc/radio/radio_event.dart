import 'package:equatable/equatable.dart';
import '../../core/constants/frequencies.dart';
import '../../data/models/station.dart';

abstract class RadioEvent extends Equatable {
  const RadioEvent();
  @override
  List<Object?> get props => [];
}

class RadioInitialized extends RadioEvent {
  const RadioInitialized();
}

// Internal — dispatched when FlutterRadioPlayer.isPlayingStream emits.
class RadioPlayerStatusChanged extends RadioEvent {
  final bool isPlaying;
  const RadioPlayerStatusChanged(this.isPlaying);
  @override
  List<Object?> get props => [isPlaying];
}

class RadioStationSelected extends RadioEvent {
  final Station station;
  const RadioStationSelected(this.station);
  @override
  List<Object?> get props => [station];
}

class RadioPlayPressed extends RadioEvent {
  const RadioPlayPressed();
}

class RadioPausePressed extends RadioEvent {
  const RadioPausePressed();
}

class RadioStopPressed extends RadioEvent {
  const RadioStopPressed();
}

class RadioPreviousPressed extends RadioEvent {
  final Band band;
  final double dialPosition;
  const RadioPreviousPressed(this.band, this.dialPosition);
  @override
  List<Object?> get props => [band, dialPosition];
}

class RadioNextPressed extends RadioEvent {
  final Band band;
  final double dialPosition;
  const RadioNextPressed(this.band, this.dialPosition);
  @override
  List<Object?> get props => [band, dialPosition];
}

class RadioMuteToggled extends RadioEvent {
  const RadioMuteToggled();
}

class RadioErrorOccurred extends RadioEvent {
  final String message;
  const RadioErrorOccurred(this.message);
  @override
  List<Object?> get props => [message];
}

class RadioStationsLoaded extends RadioEvent {
  final List<Station> stations;
  const RadioStationsLoaded(this.stations);
  @override
  List<Object?> get props => [stations];
}

class RadioSleepFadeOutPressed extends RadioEvent {
  const RadioSleepFadeOutPressed();
}
