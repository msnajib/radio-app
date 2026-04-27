abstract final class AppConstants {
  static const String appName = 'Radio';
  static const String radioBrowserBaseUrl = 'https://de1.api.radio-browser.info';

  // Snap threshold: within this range of a station, dial snaps to it
  static const double fmSnapThreshold = 0.15; // MHz
  static const int amSnapThreshold = 20;       // kHz

  // Haptic every N ticks when scrolling fast (performance guard)
  static const int hapticThrottleMs = 50;

  // Hive box names
  static const String favoritesBox = 'favorites';
  static const String settingsBox = 'settings';

  // Sleep timer options (minutes)
  static const List<int> sleepTimerOptions = [15, 30, 45, 60, 90];
}
