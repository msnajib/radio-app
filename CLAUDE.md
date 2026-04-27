# Radio App — Flutter Analog Radio

## Project Overview
Aplikasi radio streaming Android dengan UX analog — user memutar dial frekuensi (circle knob) untuk mencari stasiun, mirip radio fisik. Data stasiun dari Radio Browser API, frekuensi FM/AM di-mapping ke frekuensi real.

## Tech Stack
- **Framework:** Flutter (Android only, portrait, immersive/fullscreen)
- **State Management:** Bloc
- **Audio:** flutter_radio_player
- **Local Storage:** Hive
- **API:** Radio Browser API (https://de1.api.radio-browser.info)
- **Min Android SDK:** 23

## Dependencies
```yaml
flutter_bloc:
flutter_radio_player:
hive:
hive_flutter:
http:
google_fonts:   # untuk Geist font family
```

## Project Structure
```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/        # Frequencies, API URLs, design tokens
│   ├── theme/            # App theme (colors, typography)
│   └── utils/            # Helpers (frequency mapping, formatters)
├── data/
│   ├── models/           # Station, Frequency, Favorite
│   ├── repositories/     # RadioBrowserRepository, FavoriteRepository
│   └── datasources/      # API client, Hive local datasource
├── bloc/
│   ├── radio/            # RadioBloc (play, pause, stop, station change)
│   ├── dial/             # DialBloc (frequency position, snap, AM/FM switch)
│   └── favorites/        # FavoritesBloc (add, remove, list)
└── ui/
    ├── screens/          # HomeScreen (main radio UI)
    ├── widgets/          # CircleDial, FrequencyDisplay, RadioButton, Knob
    └── overlays/         # SleepTimer, Search, StationList (bottom sheet)
```

## Design Specs (exact values from Figma)

### Style: Flat + Neumorphic buttons
- Background dan sebagian besar elemen flat tanpa shadow
- Buttons menggunakan neumorphic inset shadow (sunken/pressed effect)
- Warna solid, rounded corners (100px/999px pill)
- Dark elements (#333) di atas light background (#EFF1F2)

### Colors
- Background: #EFF1F2
- Text primary: #333333
- Text secondary: #4E4E4E
- Accent (needle): red
- Button primary bg: #333333
- Button primary text: #FFFFFF
- Button primary inset shadow: inset 12px 12px 24px #3E3E3E, inset -12px -12px 24px #1E1E1E
- Button secondary bg: #DEE4E6
- Button secondary inset shadow: inset 12px 12px 24px #DEE4E6, inset -12px -12px 24px #B7C1C5
- Toggle border: #1C1C1C
- Toggle selected bg: #333333
- Toggle selected text: #EFF1F2
- Toggle unselected text: #1C1C1C
- Knob bg: #FFFFFF
- Knob border: #D6DEE1

### Typography (font: Geist family)
- Title "Radio": Geist Bold, 24px, #1C1C1C
- Frequency display: Geist Mono ExtraBold, 64px, #333333
- Station name: Geist Regular, 12px, #4E4E4E, uppercase
- Toggle FM/AM: Geist Bold, 12px (selected: #EFF1F2, unselected: #1C1C1C)
- Play button: Geist Bold, 14px, #FFFFFF
- Dial labels (88.5, 89.0): Geist Medium, 10px, #1C1C1C, uppercase, rotated sesuai posisi di lingkaran

### Component Specs
- **Frame:** 360 x 800 px, rounded 24px, bg #EFF1F2
- **Top bar:** padding top 36px, bottom 12px, horizontal 24px
- **FM/AM toggle:** border 1px #1C1C1C, rounded 999px, padding 2px, bg #EFF1F2. Setiap item: 44 x 32 px, selected: rounded 100px bg #333333
- **Frequency display container:** width 192px, centered horizontal (left 84px), top 180px
- **Circle dial:** diameter 656px, center horizontal, top 472px (sebagian besar di luar viewport bawah)
- **Knob:** 48 x 48 px, bg white, border 2px #D6DEE1, rounded 999px, top 534px
- **Needle:** center horizontal (left 180px), height 67px line + 20px indicator element, top 376px
- **Play button:** flex-grow, height 52px, rounded 100px, bg #333333, inset shadow
- **Prev/Next button:** 80 x 52 px, rounded 100px, bg #DEE4E6, icon 20 x 20 px, inset shadow
- **Controls bar:** gap 12px, padding left 24px, width 312px, bottom 48px

### Screen
- Orientation: portrait only, locked
- Mode: immersive/fullscreen (hide status bar)
- Safe area: top 0px, bottom 48px (cover 3-button nav worst case)
- `SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky)`
- `SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])`

### Layout (top to bottom)
1. Title "Radio" — top-left, Geist Bold 24px
2. FM/AM toggle — pill-shaped, center horizontal, top 124px
3. Frequency display "88.0" — Geist Mono ExtraBold 64px, center, top 180px
4. Station name "RADIO MUSTANG" — Geist Regular 12px uppercase, di bawah frequency
5. Circle dial — semicircle bawah layar (diameter 656px), tick marks + red needle fixed di center top dial
6. Rotary knob — 48px circle di center dial, drag untuk putar
7. Controls bar — previous(80px) | PLAY(flex) | next(80px), bottom 48px, gap 12px

## Frequency Mapping

### FM (88.0 – 108.0 MHz)
- Actual step: 0.1 MHz
- Label (garis panjang): setiap 0.5 MHz → 41 garis panjang
- Tick (garis pendek): setiap 0.1 MHz di antara label → 160 garis pendek
- Total: 201 garis pada dial
- Contoh: 88.0(panjang) — 88.1 — 88.2 — 88.3 — 88.4 — 88.5(panjang)

### AM (600 – 1600 kHz)
- Actual step: 10 kHz
- Label (garis panjang): setiap 100 kHz → 11 garis panjang (600, 700...1600)
- Tick (garis pendek): setiap 10 kHz di antara label → 90 garis pendek
- Total: 101 garis pada dial
- Range dipangkas dari standard 530-1700 karena hampir tidak ada stasiun Indonesia di luar 600-1600

### Station-to-Frequency Mapping
- Stasiun dari Radio Browser API di-assign ke frekuensi FM/AM real-nya
- Data frekuensi real di-hardcode untuk stasiun Indonesia populer (Prambors 102.2, Gen FM 98.7, dll)
- Stasiun yang tidak ada frekuensi real-nya tidak tampil di dial (hanya di search/list)

## Dial Behavior
- **Circle dial:** setengah lingkaran, tick marks di keliling, red needle fixed di top-center
- **Rotary gesture:** user drag/swipe pada knob atau area dial untuk memutar — frekuensi berubah sesuai rotasi
- **Dead zone:** dial punya titik awal (88.0 FM / 600 AM) dan akhir (108.0 FM / 1600 AM), tidak wrap around
- **Dead zone visual:** area di luar range ditampilkan abu-abu/pudar
- **Snap to station:** saat needle mendekati frekuensi yang ada stasiun, dial "magnet" snap ke frekuensi itu
- **Haptic feedback:** getar halus setiap melewati satu step (0.1 MHz FM / 10 kHz AM)
- **Momentum scroll:** swipe cepat = geser jauh, swipe pelan = geser sedikit

## Features (MVP)

### Core
- Play / Pause streaming audio
- Circle dial tuning (rotary gesture)
- FM / AM band switch (toggle, ganti range dial)
- Frequency display (angka besar, update real-time saat dial diputar)
- Station name display (tampil saat needle di frekuensi stasiun)
- Previous / Next station (skip ke stasiun terdekat)
- Background playback (flutter_radio_player handles this)
- Lock screen controls (flutter_radio_player handles this)

### Secondary
- Favorites (simpan/hapus stasiun, persist di Hive)
- Sleep timer (auto stop setelah X menit)
- Search station (by nama/genre, bottom sheet overlay)
- Station list (browsable list sebagai alternatif dial)

### Post-MVP
- Volume control
- Reconnect with exponential backoff saat connection lost
- No Station state (visual/text saat needle di frekuensi tanpa stasiun)
- Theme variants (retro, classic, modern)
- Data usage indicator
- WiFi-only mode option

## API Reference

### Radio Browser API
- Base URL: `https://de1.api.radio-browser.info`
- Stations by country: `GET /json/stations/bycountry/indonesia`
- Search: `GET /json/stations/byname/{query}`
- No auth required, no API key
- Response includes: name, url_resolved (stream URL), codec, bitrate, favicon, tags

## Commands
```bash
fvm flutter run                     # Run app
fvm flutter build apk               # Build APK
fvm flutter test                     # Run tests
fvm flutter pub get                  # Install dependencies
fvm flutter pub run build_runner build  # Generate Hive adapters
```

## Rules
- Semua button widget harus punya inset shadow (neumorphic sunken effect) — lihat Colors section untuk exact shadow values
- Frequency logic (mapping, snap, dead zone) harus terpisah dari UI di Bloc/repository
- Hardcoded station frequency data simpan di `core/constants/stations.dart`
- Handle stream error gracefully — tampilkan state error di UI, jangan crash
- Prioritaskan performa dial — 60fps saat user memutar, jangan ada jank
- Font Geist dan Geist Mono: cek google_fonts dulu, kalau tidak tersedia bundle manual di `assets/fonts/` dan daftarkan di pubspec.yaml