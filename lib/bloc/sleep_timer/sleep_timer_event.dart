import 'package:equatable/equatable.dart';

abstract class SleepTimerEvent extends Equatable {
  const SleepTimerEvent();
  @override
  List<Object?> get props => [];
}

class SleepTimerStarted extends SleepTimerEvent {
  final int minutes;
  const SleepTimerStarted(this.minutes);
  @override
  List<Object?> get props => [minutes];
}

class SleepTimerCancelled extends SleepTimerEvent {
  const SleepTimerCancelled();
}

