import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/dial/dial_bloc.dart';
import '../../bloc/dial/dial_event.dart';
import '../../bloc/dial/dial_state.dart';
import '../../bloc/radio/radio_bloc.dart';
import '../../bloc/radio/radio_event.dart';
import '../../bloc/radio/radio_state.dart';
import '../../bloc/sleep_timer/sleep_timer_bloc.dart';
import '../../bloc/sleep_timer/sleep_timer_state.dart';
import '../../core/constants/frequencies.dart';
import '../../core/services/sfx_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/frequency_mapper.dart';
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
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
                final stations = band == Band.fm
                    ? context.read<RadioBrowserRepository>().fmStationsOnDial(
                        radioState.allStations,
                      )
                    : context.read<RadioBrowserRepository>().amStationsOnDial(
                        radioState.allStations,
                      );
                dialBloc.add(DialStationsUpdated(stations));
              },
            ),
            // When band switches, refresh the station list for the new band
            BlocListener<DialBloc, DialState>(
              listenWhen: (prev, curr) => curr.band != prev.band,
              listener: (context, dialState) {
                final allStations = context.read<RadioBloc>().state.allStations;
                final repo = context.read<RadioBrowserRepository>();
                final stations = dialState.band == Band.fm
                    ? repo.fmStationsOnDial(allStations)
                    : repo.amStationsOnDial(allStations);
                context.read<DialBloc>().add(DialStationsUpdated(stations));
              },
            ),
            // Snap → auto-select station + SFX
            BlocListener<DialBloc, DialState>(
              listenWhen: (prev, curr) =>
                  curr.snappedStation != prev.snappedStation,
              listener: (context, dialState) {
                final sfx = context.read<SfxService>();
                if (dialState.snappedStation != null) {
                  final radioBloc = context.read<RadioBloc>();
                  // Skip if RadioBloc already selected this station (e.g. from prev/next)
                  if (radioBloc.state.currentStation ==
                      dialState.snappedStation) {
                    dev.log(
                      '[XYZ][HomeScreen] snap → "${dialState.snappedStation!.name}" already current, skip',
                      name: 'Home',
                    );
                    return;
                  }
                  dev.log(
                    '[XYZ][HomeScreen] snap → station "${dialState.snappedStation!.name}" — stop static, select station',
                    name: 'Home',
                  );
                  sfx.stopStaticNoise();
                  radioBloc.add(
                    RadioStationSelected(dialState.snappedStation!),
                  );
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
            // Fade out station_found when stream starts playing
            BlocListener<RadioBloc, RadioState>(
              listenWhen: (prev, curr) => !prev.isPlaying && curr.isPlaying,
              listener: (context, state) {
                dev.log(
                  '[XYZ][HomeScreen] isPlaying=true (${state.currentStation?.name}) → fadeOutStationFound',
                  name: 'Home',
                );
                context.read<SfxService>().fadeOutStationFound();
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
              // ── Top bar: title + favorite button ───────────────────
              Positioned(
                top: topPad + 36,
                left: 24,
                right: 24,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Radio', style: AppTypography.appTitle),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        _TimerButton(),
                        SizedBox(width: 16),
                        _MuteButton(),
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
                top: topPad + 290,
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

              // ── Error banner ──────────────────────────────────────
              const Positioned(
                left: 24,
                right: 24,
                bottom: 116,
                child: _ErrorBanner(),
              ),
            ],
          ),
        ),
      ),
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
              color: AppColors.textPrimary,
              size: 28,
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
                : AppColors.textPrimary,
            size: 24,
          ),
        );
      },
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
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bedtime_rounded, size: 10, color: AppColors.dialNeedle),
            const SizedBox(width: 4),
            Text(
              state.formattedRemaining,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.dialNeedle,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
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
        return BlocBuilder<RadioBloc, RadioState>(
          buildWhen: (prev, curr) =>
              prev.currentStation != curr.currentStation ||
              prev.status != curr.status,
          builder: (context, radioState) {
            int? playingTickIndex;
            if (radioState.isPlaying) {
              final station = radioState.currentStation;
              if (station != null) {
                if (dialState.band == Band.fm && station.hasFMFrequency) {
                  final pos = FrequencyMapper.fmToPosition(
                    station.fmFrequency!,
                  );
                  playingTickIndex = (pos * (FMConstants.totalTicks - 1))
                      .round();
                } else if (dialState.band == Band.am &&
                    station.hasAMFrequency) {
                  final pos = FrequencyMapper.amToPosition(
                    station.amFrequency!,
                  );
                  playingTickIndex = (pos * (AMConstants.totalTicks - 1))
                      .round();
                }
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
                      onRelease: (velocityDelta) => context
                          .read<DialBloc>()
                          .add(DialReleased(velocityDelta)),
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
              child: const Icon(Icons.fast_rewind_rounded, size: 20),
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
              child: const Icon(Icons.fast_forward_rounded, size: 20),
            ),
          ],
        );
      },
    );
  }

  void _navigatePrev(BuildContext context) {
    final dialState = context.read<DialBloc>().state;
    context.read<RadioBloc>().add(
      RadioPreviousPressed(dialState.band, dialState.position),
    );
  }

  void _navigateNext(BuildContext context) {
    final dialState = context.read<DialBloc>().state;
    context.read<RadioBloc>().add(
      RadioNextPressed(dialState.band, dialState.position),
    );
  }
}

// ── Error banner ──────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RadioBloc, RadioState>(
      buildWhen: (prev, curr) =>
          curr.status != prev.status || curr.errorMessage != prev.errorMessage,
      builder: (context, state) {
        if (state.status != RadioStatus.error) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.dialNeedle.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppColors.dialNeedle.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 14,
                color: AppColors.dialNeedle,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  state.errorMessage ?? 'Stream unavailable',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.dialNeedle,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
