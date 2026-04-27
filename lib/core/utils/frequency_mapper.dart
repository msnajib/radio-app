import '../constants/frequencies.dart';

// Maps between a dial rotation angle (0.0–1.0 normalized) and a frequency value.
// 0.0 = min frequency, 1.0 = max frequency.

abstract final class FrequencyMapper {
  // FM: normalized position → MHz (rounded to 1 decimal)
  static double positionToFM(double position) {
    final clamped = position.clamp(0.0, 1.0);
    final raw = FMConstants.minFreq + clamped * (FMConstants.maxFreq - FMConstants.minFreq);
    return (raw * 10).round() / 10.0;
  }

  // FM: MHz → normalized position
  static double fmToPosition(double freqMHz) {
    return ((freqMHz - FMConstants.minFreq) / (FMConstants.maxFreq - FMConstants.minFreq))
        .clamp(0.0, 1.0);
  }

  // AM: normalized position → kHz (rounded to nearest 10)
  static int positionToAM(double position) {
    final clamped = position.clamp(0.0, 1.0);
    final raw = AMConstants.minFreq + clamped * (AMConstants.maxFreq - AMConstants.minFreq);
    return ((raw / AMConstants.step).round() * AMConstants.step)
        .clamp(AMConstants.minFreq, AMConstants.maxFreq);
  }

  // AM: kHz → normalized position
  static double amToPosition(int freqKHz) {
    return ((freqKHz - AMConstants.minFreq) / (AMConstants.maxFreq - AMConstants.minFreq))
        .clamp(0.0, 1.0);
  }

  // FM: tick index (0-based, 0=88.0 MHz) → frequency
  static double fmTickToFreq(int index) {
    return FMConstants.minFreq + index * FMConstants.step;
  }

  // AM: tick index (0-based, 0=600 kHz) → frequency
  static int amTickToFreq(int index) {
    return AMConstants.minFreq + index * AMConstants.step;
  }

  // Whether a given FM tick index is a major (labeled) tick
  static bool isFMMajorTick(int index) {
    return index % 5 == 0; // every 0.5 MHz = every 5 steps of 0.1 MHz
  }

  // Whether a given AM tick index is a major (labeled) tick
  static bool isAMMajorTick(int index) {
    return index % 10 == 0; // every 100 kHz = every 10 steps of 10 kHz
  }
}
