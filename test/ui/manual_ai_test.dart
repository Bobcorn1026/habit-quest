import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/ai/ai_tasks.dart';
import 'package:habit_quest/ai/prompts.dart';
import 'package:habit_quest/ai/response_parser.dart';
import 'package:habit_quest/app.dart';
import 'package:habit_quest/ai/secret_store.dart';
import 'package:habit_quest/ui/screens/ai/manual_ai_screen.dart';
import 'package:habit_quest/ui/screens/settings/settings_screen.dart';

import '../ai/fixtures.dart';
import '../support/app_harness.dart';

void main() {
  late String? clipboard;

  setUp(() {
    clipboard = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            clipboard = (call.arguments as Map)['text'] as String?;
          }
          if (call.method == 'Clipboard.getData') return {'text': clipboard};
          return null;
        });
  });

  /// Opens the copy-paste screen for the forge fixture; the parsed result
  /// is passed to [onResult] when the screen pops.
  Future<void> openManual(
    WidgetTester tester, [
    void Function(ForgeResult?)? onResult,
  ]) async {
    tester.view.physicalSize = const Size(1206, 4000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      HabitQuestApp(
        home: Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () async {
                final r = await ManualAiScreen.open<ForgeResult>(
                  context,
                  title: '鍛造任務',
                  prompt: PromptBuilder.forge(forgeRequest),
                  parse: (raw) => parseForge(raw, forgeRequest),
                );
                onResult?.call(r);
              },
              child: const Text('go'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
  }

  testWidgets('copy, paste a good reply, get the result', (tester) async {
    ForgeResult? result;
    await openManual(tester, (r) => result = r);

    await tester.tap(find.text('複製咒文'));
    await tester.pump();
    expect(clipboard, contains('abc234'));
    await tester.pump(const Duration(seconds: 2));

    clipboard = forgeReply;
    await tester.tap(find.text('從剪貼簿貼上'));
    await tester.pump();
    await tester.tap(find.text('解讀回覆'));
    await tester.pumpAndSettle();

    expect(find.text('解讀回覆'), findsNothing, reason: 'screen popped');
    expect(result!.questFor('h1')!.title, '破譯古代卷軸');
  });

  testWidgets('a bad reply shows problems and a repair prompt', (tester) async {
    await openManual(tester);
    await tester.enterText(find.byType(EditableText), '抱歉我不懂');
    await tester.tap(find.text('解讀回覆'));
    await tester.pump();
    expect(find.textContaining('找不到 JSON'), findsOneWidget);

    await tester.tap(find.text('複製修正咒文'));
    await tester.pump();
    expect(clipboard, contains('你上一個回覆有以下問題'));
    expect(clipboard, contains('"abc234"'));
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('settings switches AI mode and stores the key in the keychain', (
    tester,
  ) async {
    final h = AppHarness();
    final secrets = h.secrets;
    tester.view.physicalSize = const Size(1206, 6000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: h.overrides,
        child: const HabitQuestApp(home: SettingsScreen()),
      ),
    );
    await h.settle(tester);

    await tester.tap(find.text('Claude API'));
    await h.settle(tester);
    expect(find.text('API key：尚未設定'), findsOneWidget);

    await tester.enterText(find.byType(EditableText).first, 'sk-ant-test');
    await tester.tap(find.text('儲存 key'));
    await h.settle(tester);
    expect(await secrets.read(SecretKeys.claude), 'sk-ant-test');
    expect(find.textContaining('已儲存'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await h.dispose(tester);
  });
}
