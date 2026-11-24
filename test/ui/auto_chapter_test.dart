import 'dart:convert';

import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/ai/ai_config.dart';
import 'package:habit_quest/ai/secret_store.dart';
import 'package:habit_quest/app/ai_providers.dart';
import 'package:habit_quest/data/settings_repository.dart';
import 'package:habit_quest/data/story_repository.dart';
import 'package:habit_quest/domain/chapter.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../support/app_harness.dart';

/// Answers every Claude request with a chapter for the request it read.
http.Client _claude(List<String> asked) => MockClient((req) async {
  final body = jsonDecode(utf8.decode(req.bodyBytes)) as Map;
  final prompt = ((body['messages'] as List).first as Map)['content'] as String;
  final id = RegExp(r'requestId 固定是 "(\w+)"').firstMatch(prompt)!.group(1);
  asked.add(id!);
  final chapter = jsonEncode({
    'protocol': 'hq-1',
    'requestId': id,
    'title': '自動寫好的一章',
    'body': '吟遊詩人在週一清晨寫完了這一章。',
    'choices': [
      {'label': '前進', 'hint': '', 'blessing': null},
      {'label': '休息', 'hint': '', 'blessing': null},
      {'label': '打聽', 'hint': '', 'blessing': null},
    ],
    'recap': '……',
    'qualityBonus': 0,
    'upgrades': [],
    'sideQuest': null,
  });
  return http.Response.bytes(
    utf8.encode(
      jsonEncode({
        'stop_reason': 'end_turn',
        'content': [
          {'type': 'text', 'text': chapter},
        ],
      }),
    ),
    200,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
});

void main() {
  testWidgets('with an API key the due chapter writes itself', (tester) async {
    final asked = <String>[];
    final secrets = MemorySecretStore();
    final h = _ApiHarness(secrets, _claude(asked));
    await tester.runAsync(() async {
      await h.seed();
      await secrets.write(SecretKeys.claude, 'sk-test');
      await SettingsRepository(h.db).write(
        SettingKeys.aiConfig,
        const AiConfig(mode: AiMode.claude).toJson(),
      );
    });
    await h.pump(tester);
    for (var i = 0; i < 4; i++) {
      await h.settle(tester);
    }

    expect(asked, hasLength(1));
    final latest = await tester.runAsync(() => StoryRepository(h.db).latest());
    expect(latest!.status, ChapterStatus.written);
    expect(latest.title, '自動寫好的一章');
    expect(find.text('前往抉擇'), findsOneWidget);
    await h.dispose(tester);
  });
}

class _ApiHarness extends AppHarness {
  _ApiHarness(SecretStore secrets, this.client) {
    this.secrets = secrets;
  }

  final http.Client client;

  @override
  List<Override> get overrides => [
    ...super.overrides,
    httpClientProvider.overrideWithValue(client),
  ];
}
