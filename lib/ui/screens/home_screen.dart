import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/city/city_cubit.dart';
import '../../bloc/dial/dial_bloc.dart';
import '../overlays/city_picker_overlay.dart';
import '../../bloc/dial/dial_event.dart';
import '../../bloc/dial/dial_state.dart';
import '../../bloc/radio/radio_bloc.dart';
import '../../bloc/radio/radio_event.dart';
import '../../bloc/radio/radio_state.dart';
import '../../bloc/sleep_timer/sleep_timer_bloc.dart';
import '../../bloc/sleep_timer/sleep_timer_state.dart';
import '../../bloc/theme/theme_cubit.dart';
import '../../core/constants/frequencies.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/sfx_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/radio_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/frequency_mapper.dart';
import '../../data/models/station.dart';
import '../../data/repositories/radio_browser_repository.dart';
import '../overlays/sleep_timer_overlay.dart';
import '../widgets/circle_dial.dart';
import '../widgets/frequency_display.dart';
import '../widgets/neu_button.dart';
import '../widgets/neu_toggle.dart';

// Layout per Figma (360x800px frame):
//   top 36  — title "Radio" (left) + favorite button (right)
//   top 112 — FM/AM toggle (centered)
//   top 168 — frequency display 192px wide (centered)
//   top 376 — needle top edge
//   top 472 — circle dial top edge (656px diameter)
//   top 534 — knob center
//   bottom 48 — controls bar
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // viewPadding.top = status bar height (0 when hidden, ~24–48 when visible).
    // edgeToEdge mode renders content behind the status bar, so we offset
    // top-anchored items down by that amount to keep them below the bar.
    final topPad = MediaQuery.viewPaddingOf(context).top;
    final isDark = context.watch<ThemeCubit>().brightness == Brightness.dark;
    final iconBrightness = isDark ? Brightness.light : Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: iconBrightness,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: iconBrightness,
      ),
      child: Scaffold(
        backgroundColor: context.radioTheme.background,
        body: MultiBlocListener(
          listeners: [
            // Sleep timer expired → fade out audio
            BlocListener<SleepTimerBloc, SleepTimerState>(
              listenWhen: (prev, curr) => curr.isExpired && !prev.isExpired,
              listener: (context, _) {
                dev.log(
                  '[XYZ][HomeScreen] sleep timer expired → fade out',
                  name: 'Home',
                );
                context.read<RadioBloc>().add(const RadioSleepFadeOutPressed());
              },
            ),
            // Forward loaded stations to DialBloc so it can snap
            BlocListener<RadioBloc, RadioState>(
              listenWhen: (prev, curr) => curr.allStations != prev.allStations,
              listener: (context, radioState) {
                final dialBloc = context.read<DialBloc>();
                final band = dialBloc.state.band;
                final repo = context.read<RadioBrowserRepository>();
                final stations = band == Band.fm
                    ? repo.fmStationsOnDial(radioState.allStations)
                    : repo.amStationsOnDial(radioState.allStations);
                dialBloc.add(DialStationsUpdated(stations));
              },
            ),
            // When city changes, reload dial stations filtered by the new city
            BlocListener<CityCubit, String?>(
              listener: (context, city) {
                final repo = context.read<RadioBrowserRepository>();
                final stations = repo.getDialStations(city: city);
                context.read<RadioBloc>().add(RadioStationsLoaded(stations));
              },
            ),
            // When band switches, refresh the station list for the new band + analytics
            BlocListener<DialBloc, DialState>(
              listenWhen: (prev, curr) => curr.band != prev.band,
              listener: (context, dialState) {
                final allStations = context.read<RadioBloc>().state.allStations;
                final repo = context.read<RadioBrowserRepository>();
                final stations = dialState.band == Band.fm
                    ? repo.fmStationsOnDial(allStations)
                    : repo.amStationsOnDial(allStations);
                context.read<DialBloc>().add(DialStationsUpdated(stations));
                context.read<AnalyticsService>().logBandSwitch(
                  dialState.band == Band.fm ? 'FM' : 'AM',
                );
              },
            ),
            // Snap → auto-select station + SFX + analytics dial_tune
            BlocListener<DialBloc, DialState>(
              listenWhen: (prev, curr) =>
                  curr.snappedStation != prev.snappedStation,
              listener: (context, dialState) {
                final sfx = context.read<SfxService>();
                if (dialState.snappedStation != null) {
                  final radioBloc = context.read<RadioBloc>();
                  sfx.stopStaticNoise();
                  final station = dialState.snappedStation!;
                  if (station.hasFMFrequency) {
                    context.read<AnalyticsService>().logDialTune(
                      station.fmFrequency!,
                      'FM',
                    );
                  } else if (station.hasAMFrequency) {
                    context.read<AnalyticsService>().logDialTune(
                      station.amFrequency!.toDouble(),
                      'AM',
                    );
                  }
                  if (radioBloc.state.currentStation == station) {
                    dev.log(
                      '[XYZ][HomeScreen] snap → "${station.name}" already current, skip reselect',
                      name: 'Home',
                    );
                    return;
                  }
                  dev.log(
                    '[XYZ][HomeScreen] snap → station "${station.name}" — select station',
                    name: 'Home',
                  );
                  radioBloc.add(RadioStationSelected(station));
                } else {
                  dev.log(
                    '[XYZ][HomeScreen] snap cleared → start static, stop radio',
                    name: 'Home',
                  );
                  sfx.startStaticNoise();
                  context.read<RadioBloc>().add(const RadioStopPressed());
                }
              },
            ),
            // App buka: stations pertama kali load → static kalau tidak ada snap
            BlocListener<DialBloc, DialState>(
              listenWhen: (prev, curr) =>
                  prev.stations.isEmpty && curr.stations.isNotEmpty,
              listener: (context, dialState) {
                if (dialState.snappedStation == null) {
                  dev.log(
                    '[XYZ][HomeScreen] app open — stations loaded, no snap → start static',
                    name: 'Home',
                  );
                  context.read<SfxService>().startStaticNoise();
                } else {
                  dev.log(
                    '[XYZ][HomeScreen] app open — stations loaded, snapped to "${dialState.snappedStation!.name}"',
                    name: 'Home',
                  );
                }
              },
            ),
            // Static noise: bunyi saat di frekuensi kosong
            BlocListener<DialBloc, DialState>(
              listenWhen: (prev, curr) =>
                  curr.position != prev.position && curr.snappedStation == null,
              listener: (context, _) {
                dev.log(
                  '[XYZ][HomeScreen] dial moved, no snap → start static',
                  name: 'Home',
                );
                context.read<SfxService>().startStaticNoise();
              },
            ),
            // Analytics: station_play
            BlocListener<RadioBloc, RadioState>(
              listenWhen: (prev, curr) => !prev.isPlaying && curr.isPlaying,
              listener: (context, state) {
                dev.log(
                  '[XYZ][HomeScreen] isPlaying=true (${state.currentStation?.name}) → fadeOutStationFound',
                  name: 'Home',
                );
                context.read<SfxService>().fadeOutStationFound();
                if (state.currentStation != null) {
                  context.read<AnalyticsService>().logStationPlay(state.currentStation!);
                }
              },
            ),
            // Loop station_found while buffering
            BlocListener<RadioBloc, RadioState>(
              listenWhen: (prev, curr) => !prev.isLoading && curr.isLoading,
              listener: (context, state) {
                dev.log(
                  '[XYZ][HomeScreen] isLoading=true (${state.currentStation?.name}) → loopStationFound',
                  name: 'Home',
                );
                context.read<SfxService>().loopStationFound();
              },
            ),
            // Stop station_found loop when loading ends WITHOUT playing (stop/error/cancel)
            BlocListener<RadioBloc, RadioState>(
              listenWhen: (prev, curr) =>
                  prev.isLoading && !curr.isLoading && !curr.isPlaying,
              listener: (context, state) {
                dev.log(
                  '[XYZ][HomeScreen] loading ended, not playing (status=${state.status}) → stopStationFound',
                  name: 'Home',
                );
                context.read<SfxService>().stopStationFound();
              },
            ),
            // Programmatic station change (prev/next) → jump dial to new frequency.
            // Skip if dial already snapped to this station (came from snap, not prev/next).
            BlocListener<RadioBloc, RadioState>(
              listenWhen: (prev, curr) =>
                  curr.currentStation != prev.currentStation &&
                  curr.currentStation != null,
              listener: (context, radioState) {
                final station = radioState.currentStation!;
                final dialState = context.read<DialBloc>().state;
                if (dialState.snappedStation == station) return;
                double? targetPos;
                if (dialState.band == Band.fm && station.hasFMFrequency) {
                  targetPos = FrequencyMapper.fmToPosition(
                    station.fmFrequency!,
                  );
                } else if (dialState.band == Band.am &&
                    station.hasAMFrequency) {
                  targetPos = FrequencyMapper.amToPosition(
                    station.amFrequency!,
                  );
                }
                if (targetPos != null) {
                  context.read<DialBloc>().add(DialJumpedToPosition(targetPos));
                }
              },
            ),
          ],
          child: Stack(
            children: [
              // ── Noise texture overlay ──────────────────────────────
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: const AssetImage('assets/images/noise.png'),
                      fit: BoxFit.cover,
                      opacity: 0.1,
                      colorFilter: ColorFilter.mode(
                        context.radioTheme.background,
                        BlendMode.softLight,
                      ),
                    ),
                  ),
                ),
              ),

              // ── Top bar: title + favorite button ───────────────────
              Positioned(
                top: topPad + 36,
                left: 24,
                right: 24,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const _CityPickerButton(),
                    Row(
                      spacing: 16,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _ThemeButton(),
                        const _TimerButton(),
                        const _MuteButton(),
                      ],
                    ),
                  ],
                ),
              ),

              // ── FM/AM Toggle ───────────────────────────────────────
              Positioned(
                top: topPad + 112,
                left: 0,
                right: 0,
                child: Center(child: _BandToggle()),
              ),

              // ── Frequency display ──────────────────────────────────
              Positioned(
                top: topPad + 168,
                left: 0,
                right: 0,
                child: Center(child: _FreqDisplay()),
              ),

              // ── Sleep timer countdown ───────────────────────────────
              Positioned(
                top: topPad + 312,
                left: 0,
                right: 0,
                child: const Center(child: _SleepCountdown()),
              ),

              // ── Dial + Needle + Knob — bottom-anchored so circle center
              // stays at screen bottom regardless of device height ─────
              Positioned(bottom: 0, left: 0, right: 0, child: _DialSection()),

              // ── Controls bar ──────────────────────────────────────
              const Positioned(
                left: 24,
                right: 24,
                bottom: 48,
                child: _ControlsBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── City picker button ───────────────────────────────────────────────────────

class _CityPickerButton extends StatelessWidget {
  const _CityPickerButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CityCubit, String?>(
      builder: (context, city) {
        return GestureDetector(
          onTap: () => CityPickerOverlay.show(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(city ?? 'Semua Kota', style: AppTypography.appTitle),
              const SizedBox(width: 2),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: context.radioTheme.textPrimary,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Mute/Unmute button ──────────────────────────────────────────────────────

class _MuteButton extends StatelessWidget {
  const _MuteButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RadioBloc, RadioState>(
      buildWhen: (prev, curr) => prev.isMuted != curr.isMuted,
      builder: (context, state) {
        return GestureDetector(
          onTap: () => context.read<RadioBloc>().add(const RadioMuteToggled()),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              state.isMuted
                  ? Icons.volume_off_rounded
                  : Icons.volume_up_rounded,
              key: ValueKey(state.isMuted),
              color: context.radioTheme.textPrimary,
              size: 24,
            ),
          ),
        );
      },
    );
  }
}

// ── Timer button ────────────────────────────────────────────────────────────

class _TimerButton extends StatelessWidget {
  const _TimerButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SleepTimerBloc, SleepTimerState>(
      buildWhen: (prev, curr) => prev.isActive != curr.isActive,
      builder: (context, state) {
        return GestureDetector(
          onTap: () => SleepTimerOverlay.show(context),
          child: Icon(
            Icons.bedtime_rounded,
            color: state.isActive
                ? AppColors.dialNeedle
                : context.radioTheme.textPrimary,
            size: 20,
          ),
        );
      },
    );
  }
}

// ── Theme cycle button ───────────────────────────────────────────────────────

class _ThemeButton extends StatelessWidget {
  const _ThemeButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<ThemeCubit>().cycle(),
      child: Icon(
        Icons.palette_outlined,
        color: context.radioTheme.textPrimary,
        size: 20,
      ),
    );
  }
}

// ── Sleep timer countdown ────────────────────────────────────────────────────

class _SleepCountdown extends StatelessWidget {
  const _SleepCountdown();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SleepTimerBloc, SleepTimerState>(
      buildWhen: (prev, curr) =>
          prev.remainingSeconds != curr.remainingSeconds ||
          prev.isActive != curr.isActive,
      builder: (context, state) {
        if (!state.isActive) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.red.withValues(alpha: 0.1)),
          ),
          child: Row(
            spacing: 4,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bedtime_rounded,
                size: 12,
                color: AppColors.dialNeedle,
              ),
              Text(
                state.formattedRemaining,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.dialNeedle,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Band toggle ─────────────────────────────────────────────────────────────

class _BandToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DialBloc, DialState>(
      builder: (context, state) {
        return NeuToggle(
          labels: const ['FM', 'AM'],
          selectedIndex: state.band == Band.fm ? 0 : 1,
          onChanged: (i) => context.read<DialBloc>().add(
            DialBandSwitched(i == 0 ? Band.fm : Band.am),
          ),
        );
      },
    );
  }
}

// ── Frequency display ────────────────────────────────────────────────────────

class _FreqDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DialBloc, DialState>(
      builder: (context, dialState) {
        return BlocBuilder<RadioBloc, RadioState>(
          builder: (context, radioState) {
            return FrequencyDisplay(
              dialPosition: dialState.position,
              band: dialState.band,
              stationName: radioState.currentStation?.name,
              hasError: radioState.status == RadioStatus.error,
            );
          },
        );
      },
    );
  }
}

// ── Dial section ─────────────────────────────────────────────────────────────
// Bottom-anchored: circle center stays at screen bottom on any device height.
//
// Figma 800px frame measurements from screen bottom:
//   Dial circle center  →   0 px (bottom)
//   Knob center         → 242 px  (y=558 from top → 800-558=242)
//   Needle bottom edge  → 337 px  (needle top y=376, height=87 → 800-463=337)
//
// SizedBox height=500 covers from y≈300 to screen bottom, containing all three
// elements positioned via Positioned(bottom:...) inside the inner Stack.
class _DialSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DialBloc, DialState>(
      builder: (context, dialState) {
        int? playingTickIndex;
        final snapped = dialState.snappedStation;
        if (snapped != null) {
          if (dialState.band == Band.fm && snapped.hasFMFrequency) {
            final pos = FrequencyMapper.fmToPosition(snapped.fmFrequency!);
            playingTickIndex = (pos * (FMConstants.totalTicks - 1)).round();
          } else if (dialState.band == Band.am && snapped.hasAMFrequency) {
            final pos = FrequencyMapper.amToPosition(snapped.amFrequency!);
            playingTickIndex = (pos * (AMConstants.totalTicks - 1)).round();
          }
        }
        return SizedBox(
          height: 500,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // CircleDial — gesture + rotating cross+knobs drawn inside painter
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: CircleDial(
                  position: dialState.position,
                  band: dialState.band,
                  onRotate: (delta) =>
                      context.read<DialBloc>().add(DialDragged(delta)),
                  onRelease: (velocityDelta) =>
                      context.read<DialBloc>().add(DialReleased(velocityDelta)),
                  onTick: () => context.read<SfxService>().playTick(),
                  playingTickIndex: playingTickIndex,
                ),
              ),
              // Needle — fixed at ring top, does not rotate
              const Positioned(
                bottom: 328,
                left: 0,
                right: 0,
                child: _Needle(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Needle extends StatelessWidget {
  const _Needle();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Container(width: 2, height: 20, color: AppColors.dialNeedle),
        ),
        Center(
          child: Container(
            width: 12,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.dialNeedle,
              borderRadius: BorderRadius.circular(12 / 2),
            ),
          ),
        ),
        Center(
          child: Container(width: 2, height: 80, color: AppColors.dialNeedle),
        ),
      ],
    );
  }
}

// ── Controls bar ─────────────────────────────────────────────────────────────

class _ControlsBar extends StatelessWidget {
  const _ControlsBar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RadioBloc, RadioState>(
      builder: (context, state) {
        return Row(
          children: [
            NeuButtonSecondary(
              width: 80,
              height: 52,
              onPressed: () {
                _navigatePrev(context);
              },
              child: const Icon(
                Icons.fast_rewind_rounded,
                size: 24,
                color: AppColors.buttonPrimaryBodyMid,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: NeuButtonPrimary(
                label: state.isPlaying ? 'PAUSE' : 'PLAY',
                icon: state.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                isLoading: state.isLoading,
                onPressed: () {
                  if (state.isPlaying) {
                    context.read<RadioBloc>().add(const RadioPausePressed());
                  } else {
                    context.read<RadioBloc>().add(const RadioPlayPressed());
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            NeuButtonSecondary(
              width: 80,
              height: 52,
              onPressed: () {
                _navigateNext(context);
              },
              child: const Icon(
                Icons.fast_forward_rounded,
                size: 24,
                color: AppColors.buttonPrimaryBodyMid,
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigatePrev(BuildContext context) {
    _jumpToAdjacentStation(context, next: false);
  }

  void _navigateNext(BuildContext context) {
    _jumpToAdjacentStation(context, next: true);
  }

  void _jumpToAdjacentStation(BuildContext context, {required bool next}) {
    final dialState = context.read<DialBloc>().state;
    final radioState = context.read<RadioBloc>().state;
    final repo = context.read<RadioBrowserRepository>();

    final Station? target;
    if (dialState.band == Band.fm) {
      final currentFreq =
          radioState.currentStation?.fmFrequency ??
          FrequencyMapper.positionToFM(dialState.position);
      final adj = repo.adjacentFM(radioState.allStations, currentFreq);
      target = next ? adj.next : adj.prev;
    } else {
      final currentFreq =
          radioState.currentStation?.amFrequency ??
          FrequencyMapper.positionToAM(dialState.position);
      final adj = repo.adjacentAM(radioState.allStations, currentFreq);
      target = next ? adj.next : adj.prev;
    }
    if (target == null) return;

    final pos = target.hasFMFrequency
        ? FrequencyMapper.fmToPosition(target.fmFrequency!)
        : FrequencyMapper.amToPosition(target.amFrequency!);

    final sfx = context.read<SfxService>();
    sfx.startStaticNoise();
    sfx.playTick();
    context.read<DialBloc>().add(DialJumpedToPosition(pos));
  }
}
