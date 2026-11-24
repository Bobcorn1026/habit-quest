import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the bundled pixel font so goldens show real glyphs, not boxes.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final font = FontLoader('Cubic11')
    ..addFont(rootBundle.load('assets/fonts/Cubic_11.ttf'));
  await font.load();
  await testMain();
}
