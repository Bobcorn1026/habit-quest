import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/app_localizations.dart';
import 'ui/pixel/pixel.dart';
import 'ui/screens/root_gate.dart';

/// Traditional Chinese (Taiwan) is the only UI language for now.
const appLocale = Locale.fromSubtags(
  languageCode: 'zh',
  scriptCode: 'Hant',
  countryCode: 'TW',
);

class HabitQuestApp extends StatelessWidget {
  const HabitQuestApp({super.key, this.home});

  /// Overrides the start screen (tests, previews).
  final Widget? home;

  @override
  Widget build(BuildContext context) {
    final scale = PixelTypeScale.forDevicePixelRatio(
      View.of(context).devicePixelRatio,
    );
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: buildPixelTheme(scale),
      locale: appLocale,
      supportedLocales: const [appLocale],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: home ?? const RootGate(),
    );
  }
}
