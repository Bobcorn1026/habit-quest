import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'app/app_effects.dart';
import 'app/local_profile.dart';
import 'app/player_look.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final profile = await LocalProfile.load(rootBundle);
  runApp(
    ProviderScope(
      overrides: [localProfileProvider.overrideWithValue(profile)],
      child: const AppEffects(child: PlayerLook(child: HabitQuestApp())),
    ),
  );
}
