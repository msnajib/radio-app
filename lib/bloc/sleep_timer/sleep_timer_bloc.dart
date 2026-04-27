import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'sleep_timer_event.dart';
import 'sleep_timer_state.dart';

// Internal tick event — defined here so it stays truly private to this file.
class _Ticked extends SleepTimerEvent {
  const _Ticked();
}

class SleepTimerBloc extends Bloc<SleepTimerEvent, SleepTimerState> {
  Timer? _ticker;

  SleepTimerBloc() : super(const SleepTimerState()) {
    on<SleepTimerStarted>(_onStarted);
    on<SleepTimerCancelled>(_onCancelled);
    on<_Ticked>(_onTicked);
  }

  void _onStarted(SleepTimerStarted event, Emitter<SleepTimerState> emit) {
    _ticker?.cancel();
    emit(SleepTimerState(remainingSeconds: event.minutes * 60));
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => add(const _Ticked()));
  }

  void _onCancelled(SleepTimerCancelled event, Emitter<SleepTimerState> emit) {
    _ticker?.cancel();
    _ticker = null;
    emit(const SleepTimerState());
  }

  void _onTicked(_Ticked event, Emitter<SleepTimerState> emit) {
    final remaining = state.remainingSeconds;
    if (remaining == null) return;
    if (remaining <= 1) {
      _ticker?.cancel();
      _ticker = null;
      emit(const SleepTimerState(isExpired: true));
    } else {
      emit(state.copyWith(remainingSeconds: remaining - 1));
    }
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}
