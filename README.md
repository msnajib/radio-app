# Radio

An analog-style FM/AM radio streaming app for Android, built with Flutter. Tune stations by spinning a rotary dial — just like a physical radio.

![Platform](https://img.shields.io/badge/platform-Android-green) ![Version](https://img.shields.io/badge/version-0.1.0--alpha.1-orange) ![Flutter](https://img.shields.io/badge/Flutter-3.x-blue) ![License](https://img.shields.io/badge/license-MIT-lightgrey)

---

## Features

- **Rotary dial tuning** — drag the knob to scan frequencies, with haptic feedback on every tick
- **Snap to station** — dial magnetically snaps to nearby stations
- **FM & AM bands** — toggle between FM (88.0–108.0 MHz) and AM (600–1600 kHz)
- **Live streaming** — plays internet radio streams via `flutter_radio_player`
- **Background playback** — audio continues when the screen is off or the app is in the background
- **Lock screen controls** — media controls on the lock screen
- **Previous / Next** — skip between stations, wraps around at the edges
- **Mute with fade-in** — smooth volume fade when unmuting to avoid sudden loudness
- **Sleep timer** — set a countdown (15 / 30 / 45 / 60 / 90 min or custom); audio fades out when it ends
- **Marquee station name** — scrolling running text with bullet separator and soft edge fade
- **6 themes** — Light, Dark, Retro, Midnight, Ocean, Forest; cycle with the palette button; persisted across sessions
- **Station data** — sourced live from the [Radio Browser API](https://www.radio-browser.info), filtered for Indonesian stations

## Design

Neumorphic + flat hybrid UI inspired by physical analog radio hardware.

- 6 theme variants with single-hue color scales
- Skeuomorphic chrome knob with radial gradient, grip texture, and concentric rings
- Geist / Geist Mono typefaces
- Red needle fixed at 12 o'clock; tick labels rotate around the dial arc
- Noise texture overlay on background
- Adaptive status bar icons (light/dark) per theme

## Tech Stack

| Layer | Library |
|---|---|
| Framework | Flutter (Android only, portrait, immersive fullscreen) |
| State management | `flutter_bloc` |
| Audio | `flutter_radio_player` |
| Local storage | `hive` + `hive_flutter` |
| Fonts | `google_fonts` (Geist, Geist Mono) |
| Networking | `http` |
| Station data | [Radio Browser API](https://de1.api.radio-browser.info) |

## Getting Started

### Requirements

- Flutter SDK (managed via [fvm](https://fvm.app) recommended)
- Android device or emulator (API 23+)

### Run

```bash
fvm flutter pub get
fvm flutter pub run build_runner build   # generate Hive adapters
fvm flutter run
```

### Build release APK

```bash
fvm flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

## Project Structure

```
lib/
├── main.dart
├── app.dart
├── bloc/
│   ├── dial/          # Frequency position, snap, band switch
│   ├── radio/         # Playback (play, pause, stop, mute, fade)
│   ├── theme/         # ThemeCubit — 6 variants, persistence
│   └── sleep_timer/   # Countdown timer, expire event
├── core/
│   ├── constants/     # Frequency ranges, station data, app constants
│   ├── theme/         # Colors, typography, shadows, theme variants
│   └── utils/         # Frequency mapping, formatters
├── data/
│   ├── models/        # Station, Favorite
│   ├── repositories/  # RadioBrowserRepository, FavoriteRepository
│   └── datasources/   # API client, Hive local storage
└── ui/
    ├── screens/       # HomeScreen
    ├── widgets/       # CircleDial, Knob, NeuButton, NeuToggle, FrequencyDisplay
    └── overlays/      # SleepTimerOverlay, SearchOverlay, StationListOverlay
```

## Versioning

This project follows [Semantic Versioning](https://semver.org): `MAJOR.MINOR.PATCH-pre-release+build`

| Stage | Example |
|---|---|
| Active alpha | `0.1.x-alpha.N` |
| Beta | `0.1.x-beta.N` |
| Release candidate | `0.1.x-rc.N` |
| Stable | `1.0.0` |

## License

MIT
