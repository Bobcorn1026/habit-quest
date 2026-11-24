import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The 8-bit sounds of the town.
enum SfxCue {
  /// A focus session starts.
  start,

  /// The player stops a session.
  stop,

  /// The break after a session is over.
  breakOver,
}

/// The cue's file under `assets/`, written by `docs/sfx/sfx.py`.
String sfxAsset(SfxCue cue) => switch (cue) {
  SfxCue.start => 'sfx/start.wav',
  SfxCue.stop => 'sfx/stop.wav',
  SfxCue.breakOver => 'sfx/break_over.wav',
};

/// Plays sound effects. Whether the player wants them is decided by the
/// caller.
abstract interface class Sfx {
  Future<void> play(SfxCue cue);
}

/// Plays nothing.
class SilentSfx implements Sfx {
  const SilentSfx();

  @override
  Future<void> play(SfxCue cue) async {}
}

/// Plays the bundled sounds. Returns at once: a sound never holds up the
/// timer, and a failing one is only logged.
class AudioSfx implements Sfx {
  AudioSfx();

  // Ambient: mixes with the player's music and stays quiet when the
  // ring/silent switch is on silent.
  static final _context = AudioContext(
    iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
  );

  final _pools = <SfxCue, Future<AudioPool>>{};

  @override
  Future<void> play(SfxCue cue) async => unawaited(_play(cue));

  Future<void> _play(SfxCue cue) async {
    try {
      final pool = await (_pools[cue] ??= AudioPool.create(
        source: AssetSource(sfxAsset(cue)),
        maxPlayers: 2,
        audioContext: _context,
      ));
      await pool.start(volume: 0.7);
    } catch (e) {
      _pools.remove(cue);
      debugPrint('sfx $cue: $e');
    }
  }

  Future<void> dispose() async {
    final pools = _pools.values.toList();
    _pools.clear();
    for (final pool in pools) {
      try {
        await (await pool).dispose();
      } catch (_) {}
    }
  }
}

final sfxProvider = Provider<Sfx>((ref) {
  final sfx = AudioSfx();
  ref.onDispose(sfx.dispose);
  return sfx;
});
