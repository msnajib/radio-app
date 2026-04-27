import '../constants/frequencies.dart';
import 'frequency_mapper.dart';

abstract final class Formatters {
  // FM: 98.7 → "98.7"
  static String fmFrequency(double freqMHz) => freqMHz.toStringAsFixed(1);

  // AM: 1200 → "1200"
  static String amFrequency(int freqKHz) => freqKHz.toString();

  // Frequency string from normalized dial position + band
  static String frequencyFromPosition(double position, Band band) {
    if (band == Band.fm) {
      return fmFrequency(FrequencyMapper.positionToFM(position));
    }
    return amFrequency(FrequencyMapper.positionToAM(position));
  }

  // Unit label
  static String unit(Band band) => band == Band.fm ? 'MHz' : 'kHz';
}
