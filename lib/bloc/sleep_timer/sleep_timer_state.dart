import 'package:equatable/equatable.dart';

class SleepTimerState extends Equatable {
  final int? remainingSeconds; // null = inactive
  final bool isExpired;        // one-shot pulse caught by HomeScreen listener

  const SleepTimerState({
    this.remainingSeconds,
    this.isExpired = false,
  });

  bool get isActive => remainingSeconds != null;

  String get formattedRemaining {
    if (remainingSeconds == null) return '';
    final m = remainingSeconds! ~/ 60;
    final s = remainingSeconds! % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  SleepTimerState copyWith({
    int? remainingSeconds,
    bool clearRemaining = false,
    bool? isExpired,
  }) {
    return SleepTimerState(
      remainingSeconds: clearRemaining ? null : (remainingSeconds ?? this.remainingSeconds),
      isExpired: isExpired ?? false,
    );
  }

  @override
  List<Object?> get props => [remainingSeconds, isExpired];
}
