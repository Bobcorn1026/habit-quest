import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/ai/ai_client.dart';
import 'package:habit_quest/ai/ai_error.dart';
import 'package:habit_quest/ai/prompts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'fixtures.dart';

http.Response _json(Object body, [int status = 200]) => http.Response.bytes(
  utf8.encode(jsonEncode(body)),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

void main() {
  final prompt = PromptBuilder.chapter(chapterRequest);

  group('ClaudeClient', () {
    late http.Request sent;

    ClaudeClient client(
      http.Response reply, {
      String model = 'claude-opus-5-5',
    }) => ClaudeClient(
      httpClient: MockClient((req) async {
        sent = req;
        return reply;
      }),
      apiKey: 'sk-test',
      model: model,
    );

    test('sends current headers, structured output and fallbacks', () async {
      final text = await client(
        _json({
          'stop_reason': 'end_turn',
          'content': [
            {'type': 'thinking', 'thinking': ''},
            {'type': 'text', 'text': chapterReply},
          ],
        }),
      ).complete(prompt);

      expect(text, chapterReply);
      expect(sent.url.toString(), 'https://api.anthropic.com/v1/messages');
      expect(sent.headers['x-api-key'], 'sk-test');
      expect(sent.headers['anthropic-version'], '2026-10-21');
      expect(sent.headers['anthropic-beta'], 'server-side-fallback-2026-07-01');
      final body = jsonDecode(sent.body) as Map;
      expect(body['model'], 'claude-opus-5-5');
      expect(body['fallbacks'], 'default');
      expect(body['output_config']['format']['type'], 'json_schema');
      expect(body['output_config']['effort'], 'medium');
      expect(body.containsKey('temperature'), isFalse);
      expect(body['system'], prompt.system);
    });

    test('haiku gets no fallbacks', () async {
      await client(
        _json({
          'stop_reason': 'end_turn',
          'content': [
            {'type': 'text', 'text': '{}'},
          ],
        }),
        model: 'claude-haiku-5-5',
      ).complete(prompt);
      expect(sent.headers.containsKey('anthropic-beta'), isFalse);
      expect((jsonDecode(sent.body) as Map).containsKey('fallbacks'), isFalse);
    });

    Future<AiErrorKind> failure(http.Response r) async {
      try {
        await client(r).complete(prompt);
      } on AiException catch (e) {
        return e.kind;
      }
      fail('expected an AiException');
    }

    test('maps stop reasons and HTTP errors to friendly kinds', () async {
      expect(
        await failure(_json({'stop_reason': 'refusal', 'content': []})),
        AiErrorKind.refusal,
      );
      expect(
        await failure(_json({'stop_reason': 'max_tokens', 'content': []})),
        AiErrorKind.truncated,
      );
      expect(
        await failure(
          _json({
            'error': {'type': 'authentication_error', 'message': 'bad key'},
          }, 401),
        ),
        AiErrorKind.auth,
      );
      expect(await failure(_json({'error': {}}, 429)), AiErrorKind.rateLimit);
      expect(await failure(_json({'error': {}}, 529)), AiErrorKind.overloaded);
    });
  });

  group('OpenAiCompatibleClient', () {
    test('asks for JSON mode and retries without it on 400', () async {
      final bodies = <Map>[];
      final c = OpenAiCompatibleClient(
        httpClient: MockClient((req) async {
          final body = jsonDecode(req.body) as Map;
          bodies.add(body);
          expect(
            req.url.toString(),
            'https://example.test/v1/chat/completions',
          );
          expect(req.headers['authorization'], 'Bearer k');
          if (body.containsKey('response_format')) {
            return _json({
              'error': {'message': 'unsupported'},
            }, 400);
          }
          return _json({
            'choices': [
              {
                'finish_reason': 'stop',
                'message': {'content': chapterReply},
              },
            ],
          });
        }),
        baseUrl: 'https://example.test/v1/',
        apiKey: 'k',
        model: 'm',
      );
      expect(await c.complete(prompt), chapterReply);
      expect(bodies, hasLength(2));
      expect(bodies.first['messages'][0]['role'], 'system');
    });
  });

  test('hosted plan is not available yet', () {
    expect(
      const HostedClient().complete(prompt),
      throwsA(
        isA<AiException>().having(
          (e) => e.kind,
          'kind',
          AiErrorKind.unavailable,
        ),
      ),
    );
  });
}
