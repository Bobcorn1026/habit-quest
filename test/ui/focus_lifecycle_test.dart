import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/app.dart';
import 'package:habit_quest/app/focus_service.dart';

import '../support/app_harness.dart';

void main() {
  testWidgets('leaving the app holds a running session until it is back', (
    tester,
  ) async {
    final h = AppHarness();
    await tester.runAsync(h.seed);
    await h.pump(tester);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(HabitQuestApp)),
    );
    FocusState state() => container.read(focusProvider);

    container.read(focusProvider.notifier).start();
    await h.settle(tester);
    expect(state().phase, FocusPhase.running);
    expect(h.screen.awake, isTrue);

    void go(List<AppLifecycleState> states) {
      for (final s in states) {
        tester.binding.handleAppLifecycleStateChanged(s);
      }
    }

    go(const [AppLifecycleState.inactive, AppLifecycleState.hidden]);
    await h.settle(tester);
    final hidden = await tester.runAsync(
      () => h.db.select(h.db.focusSessions).getSingle(),
    );
    expect(hidden!.hiddenAt, h.clock.now());
    expect(h.screen.awake, isFalse);

    go(const [AppLifecycleState.inactive, AppLifecycleState.resumed]);
    await h.settle(tester);
    expect(state().phase, FocusPhase.running);
    expect(h.screen.awake, isTrue);
    final back = await tester.runAsync(
      () => h.db.select(h.db.focusSessions).getSingle(),
    );
    expect(back!.hiddenAt, isNull);
    await h.dispose(tester);
  });
}
