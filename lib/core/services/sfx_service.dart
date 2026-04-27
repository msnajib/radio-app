import 'dart:async';
import 'dart:developer' as dev;
import 'package:audioplayers/audioplayers.dart';

class SfxService {
  // AudioPool uses Android SoundPool under the hood — low-latency, designed
  // for rapid repeated sound effects like dial ticks.
  AudioPool? _tickPool;
  AudioPool? _tapDownPool;
  AudioPool? _tapUpPool;

  final AudioPlayer _static = AudioPlayer();
  final AudioPlayer _found = AudioPlayer();

  Timer? _fadeTimer;

  SfxService() {
    // Sound effects must not steal audio focus from flutter_radio_player.
    // AudioFocus.none = play without requesting/changing focus ownership.
    final sfxContext = AudioContext(
      android: AudioContextAndroid(
        audioFocus: AndroidAudioFocus.none,
        usageType: AndroidUsageType.assistanceSonification,
        contentType: AndroidContentType.sonification,
      ),
    );
    _static.setAudioContext(sfxContext);
    _found.setAudioContext(sfxContext);
    _static.setReleaseMode(ReleaseMode.loop);
    _static.setVolume(0.3);
    _found.setVolume(0.7);
  }

  // Await in main.dart before runApp.
  Future<void> init() async {
    _tickPool = await AudioPool.create(
      source: AssetSource('audio/dial_tick.mp3'),
      maxPlayers: 8,
    );
    _tapDownPool = await AudioPool.create(
      source: AssetSource('audio/tap_down.mp3'),
      maxPlayers: 2,
    );
    _tapUpPool = await AudioPool.create(
      source: AssetSource('audio/tap_up.mp3'),
      maxPlayers: 2,
    );
  }

  int _lastTickMs = 0;

  Future<void> playTick() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastTickMs < 80) return;
    _lastTickMs = now;
    dev.log('[XYZ][SfxService] playTick', name: 'Sfx');
    _tickPool?.start(volume: 0.6);
  }

  Future<void> playTapDown() async {
    dev.log('[XYZ][SfxService] playTapDown', name: 'Sfx');
    await _tapDownPool?.start(volume: 0.5);
  }

  Future<void> playTapUp() async {
    dev.log('[XYZ][SfxService] playTapUp', name: 'Sfx');
    await _tapUpPool?.start(volume: 0.5);
  }

  Future<void> startStaticNoise() async {
    if (_static.state == PlayerState.playing) {
      dev.log(
        '[XYZ][SfxService] startStaticNoise — already playing, skip',
        name: 'Sfx',
      );
      return;
    }
    dev.log('[XYZ][SfxService] startStaticNoise — START', name: 'Sfx');
    await _static.play(AssetSource('audio/static_noise.mp3'));
  }

  Future<void> stopStaticNoise() {
    dev.log('[XYZ][SfxService] stopStaticNoise', name: 'Sfx');
    return _static.stop();
  }

  Future<void> playStationFound() async {
    dev.log('[XYZ][SfxService] playStationFound — one-shot', name: 'Sfx');
    _fadeTimer?.cancel();
    await _found.setVolume(0.4);
    await _found.setReleaseMode(ReleaseMode.release);
    await _found.play(AssetSource('audio/station_found.mp3'));
  }

  Future<void> loopStationFound() async {
    dev.log(
      '[XYZ][SfxService] loopStationFound — LOOP START (buffering)',
      name: 'Sfx',
    );
    _fadeTimer?.cancel();
    await _found.setVolume(0.4);
    await _found.setReleaseMode(ReleaseMode.loop);
    await _found.play(AssetSource('audio/station_found.mp3'));
  }

  Future<void> stopStationFound() async {
    dev.log(
      '[XYZ][SfxService] stopStationFound — loading ended without play',
      name: 'Sfx',
    );
    _fadeTimer?.cancel();
    await _found.stop();
    await _found.setVolume(0.7);
  }

  Future<void> fadeOutStationFound() async {
    dev.log(
      '[XYZ][SfxService] fadeOutStationFound — stream started, fading out',
      name: 'Sfx',
    );
    _fadeTimer?.cancel();
    double vol = 0.7;
    _fadeTimer = Timer.periodic(const Duration(milliseconds: 40), (t) async {
      vol -= 0.07;
      if (vol <= 0) {
        t.cancel();
        dev.log(
          '[XYZ][SfxService] fadeOutStationFound — DONE, stopped',
          name: 'Sfx',
        );
        await _found.stop();
        await _found.setVolume(0.7);
      } else {
        await _found.setVolume(vol);
      }
    });
  }

  Future<void> dispose() async {
    _fadeTimer?.cancel();
    await _tickPool?.dispose();
    await _tapDownPool?.dispose();
    await _tapUpPool?.dispose();
    await _static.dispose();
    await _found.dispose();
  }
}
