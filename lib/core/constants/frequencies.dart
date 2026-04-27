abstract final class FMConstants {
  static const double minFreq = 88.0;
  static const double maxFreq = 108.0;
  static const double step = 0.1;
  // 201 total ticks (88.0 to 108.0 inclusive at 0.1 steps)
  static const int totalTicks = 201;
  static const double labelEvery = 0.5; // major tick every 0.5 MHz
}

abstract final class AMConstants {
  static const int minFreq = 600;
  static const int maxFreq = 1600;
  static const int step = 10;
  // 101 total ticks (600 to 1600 inclusive at 10 kHz steps)
  static const int totalTicks = 101;
  static const int labelEvery = 100; // major tick every 100 kHz
}

enum Band { fm, am }
