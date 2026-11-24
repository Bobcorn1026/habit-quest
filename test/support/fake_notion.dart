import 'dart:convert';

import 'package:habit_quest/notion/ledger.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// An in-memory Notion with the ledger and budget data sources, behind a
/// [MockClient]. Like the real one, times are cut to the minute and
/// trashed pages never come back from a query.
/// The fake workspace's data sources; the app finds them by title.
const kFakeLedger = 'ds-ledger';
const kFakeBudget = 'ds-budget';

class FakeNotion {
  FakeNotion({required this.now, this.token = 'ntn_test'});

  /// The time an edit is stamped with.
  DateTime Function() now;
  final String token;

  /// Pages of the ledger by id, as Notion returns them.
  final pages = <String, Map<String, Object?>>{};
  final deleted = <String>{};

  /// Budget page ids by category.
  final budgets = {'餐飲': 'budget-meal', '娛樂': 'budget-fun'};

  /// Results per query page, to make the client follow cursors.
  int pageSize = 100;
  bool offline = false;

  /// Turns down every new page (400), like a select name with a comma.
  bool rejectCreates = false;

  /// Answers 200 with a body that isn't JSON.
  bool garbage = false;

  /// Called with `METHOD path` before each request is answered.
  void Function(String request)? onRequest;

  /// Makes the next created page's answer get lost (the page is made).
  bool loseNextCreate = false;
  bool ledgerShared = true;
  bool budgetShared = true;

  /// Requests seen, as `METHOD path`.
  final log = <String>[];
  var _next = 0;

  late final http.Client client = MockClient(_handle);

  String _stamp() {
    final t = now().toUtc();
    return DateTime.utc(
      t.year,
      t.month,
      t.day,
      t.hour,
      t.minute,
    ).toIso8601String();
  }

  static Map<String, Object?> _text(String type, String value) => {
    'type': type,
    type: [
      {
        'type': 'text',
        'text': {'content': value},
        'plain_text': value,
      },
    ],
  };

  static Map<String, Object?> _select(String? name) => {
    'type': 'select',
    'select': name == null ? null : {'name': name},
  };

  /// A row as the player (or Claude) would add it in Notion; its id.
  String addRow({
    String title = '午餐',
    int? amount = 120,
    bool? income = false,
    String? category = '餐飲',
    String? account,
    String? source = 'Claude 記帳',
    String? date = '2026-11-20',
    String? appId,
    String note = '',
  }) {
    final id = 'page-${++_next}';
    final stamp = _stamp();
    pages[id] = {
      'object': 'page',
      'id': id,
      'created_time': stamp,
      'last_edited_time': stamp,
      'in_trash': false,
      'properties': {
        LedgerProps.title: {'id': 'title', ..._text('title', title)},
        LedgerProps.amount: {'type': 'number', 'number': amount},
        LedgerProps.flow: _select(
          income == null
              ? null
              : income
              ? kFlowIncome
              : kFlowExpense,
        ),
        LedgerProps.category: _select(category),
        LedgerProps.account: _select(account),
        LedgerProps.source: _select(source),
        LedgerProps.date: {
          'type': 'date',
          'date': date == null ? null : {'start': date},
        },
        LedgerProps.appId: _text('rich_text', appId ?? ''),
        LedgerProps.note: _text('rich_text', note),
        LedgerProps.budget: {'type': 'relation', 'relation': <Object?>[]},
      },
    };
    return id;
  }

  Map<String, Object?> props(String id) =>
      (pages[id]!['properties']! as Map).cast<String, Object?>();

  String? selectOf(String id, String name) =>
      ((props(id)[name]! as Map)['select'] as Map?)?['name'] as String?;

  Object? numberOf(String id) =>
      (props(id)[LedgerProps.amount]! as Map)['number'];

  String textOf(String id, String name) {
    final p = props(id)[name]! as Map;
    return ((p['title'] ?? p['rich_text']) as List)
        .map((t) => (t as Map)['plain_text'])
        .join();
  }

  List<Object?> relationOf(String id) =>
      (props(id)[LedgerProps.budget] as Map?)?['relation'] as List? ?? const [];

  /// Edits [id] the way the Notion app would: new values, new edit time.
  void edit(
    String id, {
    int? amount,
    String? account,
    String? category,
    String? date,
    bool clearAccount = false,
  }) {
    final p = props(id);
    if (amount != null) {
      p[LedgerProps.amount] = {'type': 'number', 'number': amount};
    }
    if (account != null || clearAccount) {
      p[LedgerProps.account] = _select(account);
    }
    if (category != null) p[LedgerProps.category] = _select(category);
    if (date != null) {
      p[LedgerProps.date] = {
        'type': 'date',
        'date': {'start': date},
      };
    }
    pages[id]!['last_edited_time'] = _stamp();
  }

  void trash(String id, {bool value = true, bool bump = true}) {
    pages[id]!['in_trash'] = value;
    if (bump) pages[id]!['last_edited_time'] = _stamp();
  }

  void deleteForever(String id) {
    pages.remove(id);
    deleted.add(id);
  }

  /// Pages created by the app.
  Iterable<String> get fromApp =>
      pages.keys.where((id) => selectOf(id, LedgerProps.source) == kSourceApp);

  Future<http.Response> _handle(http.Request request) async {
    final path = request.url.path.replaceFirst('/v1/', '');
    log.add('${request.method} $path');
    onRequest?.call('${request.method} $path');
    if (offline) throw http.ClientException('offline', request.url);
    if (garbage) return http.Response('oops', 200);
    if (request.headers['Authorization'] != 'Bearer $token') {
      return _error(401, 'unauthorized');
    }
    final body = request.body.isEmpty
        ? const <String, Object?>{}
        : (jsonDecode(request.body) as Map).cast<String, Object?>();
    final parts = path.split('/');
    switch ((request.method, parts)) {
      case ('POST', ['search']):
        return _search(body);
      case ('GET', ['data_sources', final id]):
        if (id != kFakeLedger || !ledgerShared) {
          return _error(404, 'object_not_found');
        }
        return _ok({
          'object': 'data_source',
          'id': id,
          'properties': {
            LedgerProps.budget: {
              'type': 'relation',
              'relation': {'data_source_id': kFakeBudget},
            },
          },
        });
      case ('POST', ['data_sources', final id, 'query']):
        return _query(id, body);
      case ('POST', ['pages']):
        return _create(body);
      case ('PATCH', ['pages', final id]):
        final page = pages[id];
        if (page == null) return _error(404, 'object_not_found');
        // Like Notion: a page in the trash can't be edited.
        if (page['in_trash'] == true) return _error(400, 'validation_error');
        final changes = body['properties'];
        if (changes is Map) {
          for (final MapEntry(:key, :value) in changes.entries) {
            props(id)['$key'] = _asResponse((value as Map).cast());
          }
        }
        if (body['in_trash'] case final bool trashed) {
          page['in_trash'] = trashed;
        }
        page['last_edited_time'] = _stamp();
        return _ok(page);
      case ('GET', ['pages', final id]):
        final page = pages[id];
        return page == null ? _error(404, 'object_not_found') : _ok(page);
    }
    return _error(400, 'validation_error');
  }

  /// Data sources shared with the integration whose title has the query;
  /// a look-alike comes first, so the app must match the title exactly.
  http.Response _search(Map<String, Object?> body) {
    final query = '${body['query'] ?? ''}';
    Map<String, Object?> source(String id, String title) => {
      'object': 'data_source',
      'id': id,
      'title': [
        {'type': 'text', 'plain_text': title},
      ],
    };
    return _ok({
      'object': 'list',
      'results':
          [
                if (ledgerShared) ...[
                  source('ds-old-ledger', '$kLedgerTitle（舊）'),
                  source(kFakeLedger, kLedgerTitle),
                ],
              ]
              .where(
                (r) => '${(r['title']! as List).first['plain_text']}'.contains(
                  query,
                ),
              )
              .toList(),
      'has_more': false,
      'next_cursor': null,
    });
  }

  http.Response _query(String id, Map<String, Object?> body) {
    List<Map<String, Object?>> all;
    if (id == kFakeBudget) {
      if (!budgetShared) return _error(404, 'object_not_found');
      all = [
        for (final MapEntry(:key, :value) in budgets.entries)
          {
            'object': 'page',
            'id': value,
            'properties': {'分類': _text('title', key)},
          },
      ];
    } else if (id == kFakeLedger && ledgerShared) {
      final filter = body['filter'] as Map?;
      final appId = (filter?['rich_text'] as Map?)?['equals'];
      final field = filter?['timestamp'] as String?;
      final from = field == null
          ? null
          : DateTime.parse((filter![field] as Map)['on_or_after'] as String);
      all =
          [
            for (final page in pages.values)
              if (page['in_trash'] != true &&
                  (appId == null ||
                      textOf('${page['id']}', LedgerProps.appId) == appId) &&
                  (from == null ||
                      !DateTime.parse(page[field]! as String).isBefore(from)))
                page,
          ]..sort(
            (a, b) => (a['last_edited_time']! as String).compareTo(
              b['last_edited_time']! as String,
            ),
          );
    } else {
      return _error(404, 'object_not_found');
    }
    final start = int.tryParse('${body['start_cursor'] ?? 0}') ?? 0;
    final end = (start + pageSize).clamp(0, all.length);
    return _ok({
      'object': 'list',
      'results': all.sublist(start, end),
      'has_more': end < all.length,
      'next_cursor': end < all.length ? '$end' : null,
    });
  }

  http.Response _create(Map<String, Object?> body) {
    if (rejectCreates) return _error(400, 'validation_error');
    final parent = body['parent']! as Map;
    if (parent['data_source_id'] != kFakeLedger) {
      return _error(404, 'object_not_found');
    }
    final id = 'page-${++_next}';
    final stamp = _stamp();
    final properties = <String, Object?>{
      for (final MapEntry(:key, :value) in (body['properties']! as Map).entries)
        '$key': _asResponse((value as Map).cast()),
    };
    pages[id] = {
      'object': 'page',
      'id': id,
      'created_time': stamp,
      'last_edited_time': stamp,
      'in_trash': false,
      'properties': properties,
    };
    if (loseNextCreate) {
      loseNextCreate = false;
      return _error(504, 'gateway_timeout');
    }
    return _ok(pages[id]!);
  }

  /// A property value as written, as Notion would return it.
  static Map<String, Object?> _asResponse(Map<String, Object?> value) {
    for (final type in ['title', 'rich_text']) {
      if (value[type] case final List parts) {
        return _text(
          type,
          parts.map((t) => ((t as Map)['text'] as Map)['content']).join(),
        );
      }
    }
    final type = value.keys.single;
    return {'type': type, type: value[type]};
  }

  static http.Response _ok(Object body) => http.Response(
    jsonEncode(body),
    200,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );

  static http.Response _error(int status, String code) => http.Response(
    jsonEncode({
      'object': 'error',
      'status': status,
      'code': code,
      'message': code,
    }),
    status,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}
