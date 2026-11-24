import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/app.dart';
import 'package:habit_quest/app/focus_service.dart';
import 'package:habit_quest/data/settings_repository.dart';
import 'package:habit_quest/domain/focus_settings.dart';
import 'package:habit_quest/ui/screens/focus/focus_screen.dart';

import '../support/app_harness.dart';

Text _clock(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(const Key('focus-clock')));

void main() {
  testWidgets('the town tab leads to the training ground; leaving a running '
      'session asks first', (tester) async {
    final h = AppHarness();
    await tester.runAsync(h.seed);
    await h.pump(tester);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(HabitQuestApp)),
    );

    await tester.tap(find.text('城鎮').last);
    await h.settle(tester);
    expect(find.text('修練場'), findsOneWidget);
    expect(find.text('公會商店・旅店'), findsOneWidget);
    expect(find.text('銀行開戶後開張'), findsOneWidget);
    expect(find.text('把現實的錢分進各種用途的帳戶'), findsOneWidget);
    expect(find.text('今天還欠 50 分鐘'), findsOneWidget);

    await tester.tap(find.text('修練場'));
    await h.settle(tester);
    await tester.pump(const Duration(seconds: 1));
    expect(_clock(tester).data, '-50:00');

    await tester.tap(find.text('開始專注'));
    await h.settle(tester);
    expect(container.read(focusProvider).phase, FocusPhase.running);
    // Ticks keep coming; a gap of more than 30 s would count as being away.
    for (var i = 0; i < 30; i++) {
      h.clock.advance(const Duration(seconds: 10));
      await tester.pump(const Duration(seconds: 1));
      await h.settle(tester);
    }
    expect(_clock(tester).data, '-45:00');
    expect(find.text('專注中・這一輪 05:00'), findsOneWidget);

    // Back asks before ending the session; staying keeps it running.
    await tester.tap(find.text('←'));
    await h.settle(tester);
    expect(find.text('要結束這一輪專注嗎？'), findsOneWidget);
    await tester.tap(find.text('繼續專注'));
    await h.settle(tester);
    expect(container.read(focusProvider).phase, FocusPhase.running);
    expect(find.byType(FocusScreen), findsOneWidget);

    await tester.tap(find.text('←'));
    await h.settle(tester);
    await tester.tap(find.text('結束並離開'));
    await h.settle(tester);
    await tester.pump(const Duration(seconds: 1));
    expect(container.read(focusProvider).phase, FocusPhase.resting);
    expect(find.byType(FocusScreen), findsNothing);
    expect(find.text('休息中・今天 -45:00'), findsOneWidget);
    await h.dispose(tester);
  });

  testWidgets('power saving darkens the screen until tapped; switches are '
      'saved', (tester) async {
    final h = AppHarness();
    await tester.runAsync(h.seed);
    await h.pump(tester, home: const FocusScreen());
    final chrome = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method.startsWith('SystemChrome.setEnabledSystemUI')) {
          chrome.add(call);
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await tester.tap(find.text('開始專注'));
    await h.settle(tester);
    await tester.tap(find.text('省電模式'));
    await h.settle(tester);
    expect(find.byKey(const Key('power-save')), findsOneWidget);
    expect(h.screen.brightness, 0.05);
    // The status bar goes away with everything else.
    expect(chrome.map((c) => c.method), [
      'SystemChrome.setEnabledSystemUIOverlays',
    ]);
    expect(chrome.single.arguments, isEmpty);

    await tester.tap(find.byKey(const Key('power-save')));
    await h.settle(tester);
    expect(find.byKey(const Key('power-save')), findsNothing);
    expect(h.screen.brightness, isNull);
    expect(chrome.map((c) => (c.method, c.arguments)).last, (
      'SystemChrome.setEnabledSystemUIMode',
      'SystemUiMode.edgeToEdge',
    ));

    // On/off pairs in order: sound, time of day, hidden numbers.
    await tester.tap(find.text('開').at(1));
    await h.settle(tester);
    expect(find.text('現在 10:00'), findsOneWidget);
    await tester.tap(find.text('開').at(2));
    await h.settle(tester);
    expect(_clock(tester).data, '・・・');

    final saved = FocusSettings.fromJson(
      await tester.runAsync<Object?>(
        () => SettingsRepository(h.db).read(SettingKeys.focus),
      ),
    );
    expect(saved.showClock, isTrue);
    expect(saved.hideTimer, isTrue);
    await h.dispose(tester);
  });
}
