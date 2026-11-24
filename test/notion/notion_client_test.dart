import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/notion/notion_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

http.Response _json(Object body, [int status = 200, Map<String, String>? h]) =>
    http.Response.bytes(
      utf8.encode(jsonEncode(body)),
      status,
      headers: {'content-type': 'application/json; charset=utf-8', ...?h},
    );

void main() {
  late List<http.Request> requests;
  late List<Duration> slept;

  NotionClient make(
    http.Response Function(http.Request req, int n) respond, {
    Object? throwOnSend,
  }) {
    final mock = MockClient((req) async {
      requests.add(req);
      if (throwOnSend != null) throw throwOnSend;
      return respond(req, requests.length);
    });
    return NotionClient(
      httpClient: mock,
      token: 'secret_tok',
      sleep: (d) async => slept.add(d),
    );
  }

  setUp(() {
    requests = [];
    slept = [];
  });

  Map<String, Object?> body(http.Request r) =>
      jsonDecode(r.body) as Map<String, Object?>;

  test('headers and base url', () async {
    final c = make((r, n) => _json({'ok': true}));
    await c.dataSource('abc');
    final r = requests.single;
    expect(r.method, 'GET');
    expect(r.url.toString(), 'https://api.notion.com/v1/data_sources/abc');
    expect(r.headers['Authorization'], 'Bearer secret_tok');
    expect(r.headers['Notion-Version'], NotionClient.version);
    expect(NotionClient.version, '2026-03-11');
    expect(r.headers['Content-Type'], contains('application/json'));
  });

  group('queryAll', () {
    test('follows the cursor across pages', () async {
      final c = make((r, n) {
        return switch (n) {
          1 => _json({
            'results': [
              {'id': 'a'},
              {'id': 'b'},
            ],
            'has_more': true,
            'next_cursor': 'c1',
          }),
          2 => _json({
            'results': [
              {'id': 'c'},
            ],
            'has_more': true,
            'next_cursor': 'c2',
          }),
          _ => _json({
            'results': [
              {'id': 'd'},
            ],
            'has_more': false,
            'next_cursor': null,
          }),
        };
      });
      final pages = await c.queryAll('ds1');
      expect(pages.map((p) => p['id']), ['a', 'b', 'c', 'd']);
      expect(requests, hasLength(3));
      expect(requests[0].url.path, '/v1/data_sources/ds1/query');
      expect(requests[0].method, 'POST');
      expect(body(requests[0]).containsKey('start_cursor'), false);
      expect(body(requests[1])['start_cursor'], 'c1');
      expect(body(requests[2])['start_cursor'], 'c2');
      for (final r in requests) {
        expect(body(r)['page_size'], 100);
        expect(body(r)['sorts'], [
          {'timestamp': 'last_edited_time', 'direction': 'ascending'},
        ]);
        expect(body(r).containsKey('filter'), false);
      }
    });

    test('sends filter only when given', () async {
      final c = make((r, n) => _json({'results': [], 'has_more': false}));
      final filter = {
        'property': '收支',
        'select': {'equals': '支出'},
      };
      await c.queryAll('ds', filter: filter);
      expect(body(requests.single)['filter'], filter);
    });

    test('onlyProperties becomes filter_properties', () async {
      final c = make((r, n) => _json({'results': [], 'has_more': false}));
      await c.queryAll('ds', onlyProperties: ['title']);
      expect(requests.single.url.queryParametersAll['filter_properties'], [
        'title',
      ]);
      expect(requests.single.url.query, 'filter_properties=title');
    });

    test('no query string without onlyProperties', () async {
      final c = make((r, n) => _json({'results': [], 'has_more': false}));
      await c.queryAll('ds');
      expect(requests.single.url.hasQuery, false);
    });
  });

  group('retries', () {
    test('429 honours retry-after', () async {
      final c = make(
        (r, n) => n == 1
            ? _json({'code': 'rate_limited'}, 429, {'retry-after': '2'})
            : _json({'ok': true}),
      );
      expect(await c.dataSource('x'), {'ok': true});
      expect(slept, [const Duration(seconds: 2)]);
      expect(requests, hasLength(2));
    });

    test('429 without header backs off exponentially', () async {
      final c = make(
        (r, n) => n <= 2 ? _json({'code': 'rate_limited'}, 429) : _json({}),
      );
      await c.dataSource('x');
      expect(slept, [const Duration(seconds: 1), const Duration(seconds: 2)]);
    });

    test('gives up after maxRetries', () async {
      final c = make((r, n) => _json({'code': 'rate_limited'}, 429));
      await expectLater(
        c.dataSource('x'),
        throwsA(isA<NotionException>().having((e) => e.status, 'status', 429)),
      );
      expect(requests, hasLength(4));
      expect(slept, hasLength(3));
    });

    test('529 is retried', () async {
      final c = make(
        (r, n) => n == 1 ? _json({'code': 'overloaded'}, 529) : _json({}),
      );
      await c.dataSource('x');
      expect(requests, hasLength(2));
    });

    test('502 retried on queryAll, page and updatePage', () async {
      for (final call in <Future<Object?> Function(NotionClient)>[
        (c) => c.queryAll('ds'),
        (c) => c.page('p'),
        (c) => c.updatePage('p', inTrash: true),
      ]) {
        requests.clear();
        final c = make(
          (r, n) => n == 1
              ? _json({'code': 'bad_gateway'}, 502)
              : _json({'results': [], 'has_more': false}),
        );
        await call(c);
        expect(requests, hasLength(2));
      }
    });

    test('502 on createPage is not retried', () async {
      final c = make((r, n) => _json({'code': 'bad_gateway'}, 502));
      await expectLater(
        c.createPage('ds', {}),
        throwsA(isA<NotionException>().having((e) => e.status, 'status', 502)),
      );
      expect(requests, hasLength(1));
      expect(slept, isEmpty);
    });
  });

  group('page', () {
    test('null on 404', () async {
      final c = make((r, n) => _json({'code': 'object_not_found'}, 404));
      expect(await c.page('p'), isNull);
    });

    test('map on 200', () async {
      final c = make((r, n) => _json({'id': 'p'}));
      expect(await c.page('p'), {'id': 'p'});
      expect(requests.single.url.path, '/v1/pages/p');
    });

    test('other errors throw', () async {
      final c = make((r, n) => _json({'code': 'unauthorized'}, 401));
      await expectLater(c.page('p'), throwsA(isA<NotionException>()));
    });
  });

  group('errors', () {
    test('ClientException becomes offline', () async {
      final c = make(
        (r, n) => _json({}),
        throwOnSend: http.ClientException('no network'),
      );
      await expectLater(
        c.dataSource('x'),
        throwsA(
          isA<NotionException>()
              .having((e) => e.status, 'status', 0)
              .having((e) => e.offline, 'offline', true),
        ),
      );
    });

    test('maps a 401 body', () async {
      final c = make(
        (r, n) => _json({
          'object': 'error',
          'status': 401,
          'code': 'unauthorized',
          'message': 'API token is invalid.',
        }, 401),
      );
      await expectLater(
        c.dataSource('x'),
        throwsA(
          isA<NotionException>()
              .having((e) => e.status, 'status', 401)
              .having((e) => e.code, 'code', 'unauthorized')
              .having((e) => e.message, 'message', 'API token is invalid.')
              .having((e) => e.badToken, 'badToken', true),
        ),
      );
    });

    test('non-JSON error body does not crash', () async {
      final c = make((r, n) => http.Response('<html>nope</html>', 400));
      await expectLater(
        c.dataSource('x'),
        throwsA(
          isA<NotionException>()
              .having((e) => e.status, 'status', 400)
              .having((e) => e.code, 'code', 'error'),
        ),
      );
    });

    test('friendly text', () {
      for (final e in const [
        NotionException(0, 'offline', ''),
        NotionException(401, 'unauthorized', ''),
        NotionException(404, 'object_not_found', ''),
        NotionException(429, 'rate_limited', ''),
        NotionException(500, 'internal', ''),
      ]) {
        expect(e.friendly, isNotEmpty);
        expect(RegExp(r'[一-鿿]').hasMatch(e.friendly), true);
      }
      expect(const NotionException(404, 'x', '').notShared, true);
    });
  });

  group('writes', () {
    test('createPage body', () async {
      final c = make((r, n) => _json({'id': 'new'}));
      final props = {
        '金額': {'number': 5},
      };
      expect(await c.createPage('ds1', props), {'id': 'new'});
      final r = requests.single;
      expect(r.method, 'POST');
      expect(r.url.path, '/v1/pages');
      expect(body(r), {
        'parent': {'type': 'data_source_id', 'data_source_id': 'ds1'},
        'properties': props,
      });
    });

    test('updatePage trash has no properties key', () async {
      final c = make((r, n) => _json({'id': 'p'}));
      await c.updatePage('p', inTrash: true);
      final r = requests.single;
      expect(r.method, 'PATCH');
      expect(r.url.path, '/v1/pages/p');
      expect(body(r), {'in_trash': true});
    });
  });

  test('decodes Chinese response bodies', () async {
    final c = make(
      (r, n) => _json({
        'results': [
          {'id': '午餐'},
        ],
        'has_more': false,
      }),
    );
    final pages = await c.queryAll('ds');
    expect(pages.single['id'], '午餐');
  });
}
