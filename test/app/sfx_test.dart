import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/app/sfx.dart';

void main() {
  test('every cue has a bundled sound', () {
    expect(sfxAsset(SfxCue.breakOver), 'sfx/break_over.wav');
    for (final cue in SfxCue.values) {
      expect(
        File('assets/${sfxAsset(cue)}').existsSync(),
        isTrue,
        reason: '$cue: run python3 docs/sfx/sfx.py',
      );
    }
    expect(File('pubspec.yaml').readAsStringSync(), contains('- assets/sfx/'));
  });
}
