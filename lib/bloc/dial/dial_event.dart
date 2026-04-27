import 'package:equatable/equatable.dart';
import '../../core/constants/frequencies.dart';
import '../../data/models/station.dart';

abstract class DialEvent extends Equatable {
  const DialEvent();
  @override
  List<Object?> get props => [];
}

// User dragged the dial — delta is normalized (-1.0 to 1.0 range per full rotation)
class DialDragged extends DialEvent {
  final double delta;
  const DialDragged(this.delta);
  @override
  List<Object?> get props => [delta];
}

// User released the dial (momentum handled by bloc)
class DialReleased extends DialEvent {
  final double velocityDelta;
  const DialReleased(this.velocityDelta);
  @override
  List<Object?> get props => [velocityDelta];
}

// Jump directly to a normalized position (e.g. prev/next station)
class DialJumpedToPosition extends DialEvent {
  final double position;
  const DialJumpedToPosition(this.position);
  @override
  List<Object?> get props => [position];
}

// FM/AM band switched
class DialBandSwitched extends DialEvent {
  final Band band;
  const DialBandSwitched(this.band);
  @override
  List<Object?> get props => [band];
}

// Update the list of stations used for snap detection (forwarded from RadioBloc state).
class DialStationsUpdated extends DialEvent {
  final List<Station> stations;
  const DialStationsUpdated(this.stations);
  @override
  List<Object?> get props => [stations];
}

// Snap to station completed (triggered after snap detected)
class DialSnapped extends DialEvent {
  final double position;
  const DialSnapped(this.position);
  @override
  List<Object?> get props => [position];
}
