import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';

void main() {
  testWidgets('opening the app starts the week at the training ground', (
    tester,
  ) async {
    final h = AppHarness();
    await tester.runAsync(h.seed);
    await h.pump(tester);

    final rows = await tester.runAsync(
      () => h.db.select(h.db.focusWeeks).get(),
    );
    expect(rows!.single.fromDay, h.today);
    await h.dispose(tester);
  });

  testWidgets('nothing starts before onboarding', (tester) async {
    final h = AppHarness();
    await h.pump(tester);

    final rows = await tester.runAsync(
      () => h.db.select(h.db.focusWeeks).get(),
    );
    expect(rows, isEmpty);
    await h.dispose(tester);
  });
}
