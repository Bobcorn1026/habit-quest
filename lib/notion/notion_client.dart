import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Why a Notion call failed, in words for the settings page.
class NotionException implements Exception {
  const NotionException(this.status, this.code, this.message);

  /// 0 when the request never got an answer (offline, timed out).
  final int status;
  final String code;
  final String message;

  bool get offline => status == 0;

  /// Worth trying again later as a whole: offline, a bad token, busy or
  /// broken on Notion's side. Anything else is about one page.
  bool get passing =>
      offline || badToken || status == 409 || status == 429 || status >= 500;
  bool get badToken => status == 401;

  /// The data source is gone or not shared with the integration.
  bool get notShared => status == 404;

  /// What to tell the player.
  String get friendly => switch (this) {
    _ when code == 'bank_closed' => '銀行還沒開戶：先到城鎮的銀行開戶，再來連動',
    _ when offline => '連不上 Notion，晚點會再試',
    _ when badToken => '金鑰不對，請重新貼一次',
    _ when notShared => '找不到記帳本：記得在 Notion 把「記帳」頁面分享給這個連線',
    _ when status == 429 => 'Notion 說太忙了，晚點會再試',
    _ => 'Notion 回了錯誤（$status $code）',
  };

  @override
  String toString() => 'NotionException($status $code: $message)';
}

/// Talks to the Notion REST API with an internal integration's token.
///
/// Rate limits (429) and overload (529) are retried after `Retry-After`;
/// server errors are retried only for requests that are safe to repeat,
/// since a page creation that failed with a 5xx may still have happened.
class NotionClient {
  NotionClient({
    required http.Client httpClient,
    required String token,
    Future<void> Function(Duration)? sleep,
    this.maxRetries = 3,
  }) : _http = httpClient,
       _bearer = token,
       _sleep = sleep ?? Future<void>.delayed;

  static const version = '2026-03-11';
  static final _base = Uri.parse('https://api.notion.com/v1/');
  static const _timeout = Duration(seconds: 20);

  final http.Client _http;
  final String _bearer;
  final Future<void> Function(Duration) _sleep;
  final int maxRetries;

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $_bearer',
    'Notion-Version': version,
    'Content-Type': 'application/json',
  };

  Future<Map<String, Object?>> _send(
    String method,
    String path, {
    Map<String, Object?>? body,
    Map<String, List<String>>? query,
    bool repeatable = true,
  }) async {
    final uri = _base
        .resolve(path)
        .replace(queryParameters: query?.isEmpty ?? true ? null : query);
    for (var attempt = 0; ; attempt++) {
      final request = http.Request(method, uri)..headers.addAll(_headers);
      if (body != null) request.body = jsonEncode(body);
      http.Response response;
      try {
        response = await http.Response.fromStream(
          await _http.send(request).timeout(_timeout),
        ).timeout(_timeout);
      } on Exception catch (e) {
        throw NotionException(0, 'offline', '$e');
      }
      final status = response.statusCode;
      if (status >= 200 && status < 300) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        return decoded is Map ? decoded.cast<String, Object?>() : const {};
      }
      final retry =
          status == 429 ||
          status == 529 ||
          status == 409 ||
          (repeatable && status >= 500 && status < 600);
      if (retry && attempt < maxRetries) {
        final after = int.tryParse(response.headers['retry-after'] ?? '');
        await _sleep(Duration(seconds: (after ?? (1 << attempt)).clamp(1, 60)));
        continue;
      }
      throw _error(response);
    }
  }

  static NotionException _error(http.Response response) {
    var code = 'error';
    var message = '';
    try {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      if (body is Map) {
        code = '${body['code'] ?? code}';
        message = '${body['message'] ?? ''}';
      }
    } on FormatException {
      // Not JSON; the status says enough.
    }
    return NotionException(response.statusCode, code, message);
  }

  /// The data source's schema; a cheap way to check the token and sharing.
  Future<Map<String, Object?>> dataSource(String id) =>
      _send('GET', 'data_sources/$id');

  /// The first data source shared with the integration whose title is
  /// exactly [title]; null when there is none.
  Future<String?> findDataSource(String title) async {
    String? cursor;
    do {
      final result = await _send(
        'POST',
        'search',
        body: {
          'query': title,
          'filter': {'property': 'object', 'value': 'data_source'},
          'page_size': 100,
          'start_cursor': ?cursor,
        },
      );
      for (final hit in (result['results'] as List? ?? const [])) {
        if (hit is! Map) continue;
        final words = hit['title'];
        final name = words is List
            ? words
                  .map((w) => w is Map ? '${w['plain_text'] ?? ''}' : '')
                  .join()
            : '';
        if (name.trim() == title) return '${hit['id']}';
      }
      cursor = result['has_more'] == true
          ? result['next_cursor'] as String?
          : null;
    } while (cursor != null);
    return null;
  }

  /// Every page of [dataSourceId] that matches [filter], oldest edit first,
  /// following the cursor to the end. Pages in the trash never come back.
  Future<List<Map<String, Object?>>> queryAll(
    String dataSourceId, {
    Map<String, Object?>? filter,
    List<String>? onlyProperties,
  }) async {
    final pages = <Map<String, Object?>>[];
    String? cursor;
    do {
      final result = await _send(
        'POST',
        'data_sources/$dataSourceId/query',
        query: onlyProperties == null
            ? null
            : {'filter_properties': onlyProperties},
        body: {
          'filter': ?filter,
          'sorts': [
            {'timestamp': 'last_edited_time', 'direction': 'ascending'},
          ],
          'page_size': 100,
          'start_cursor': ?cursor,
        },
      );
      for (final page in (result['results'] as List? ?? const [])) {
        if (page is Map) pages.add(page.cast<String, Object?>());
      }
      cursor = result['has_more'] == true
          ? result['next_cursor'] as String?
          : null;
    } while (cursor != null);
    return pages;
  }

  /// A new page in [dataSourceId]. Not retried on server errors.
  Future<Map<String, Object?>> createPage(
    String dataSourceId,
    Map<String, Object?> properties,
  ) => _send(
    'POST',
    'pages',
    repeatable: false,
    body: {
      'parent': {'type': 'data_source_id', 'data_source_id': dataSourceId},
      'properties': properties,
    },
  );

  Future<Map<String, Object?>> updatePage(
    String pageId, {
    Map<String, Object?>? properties,
    bool? inTrash,
  }) => _send(
    'PATCH',
    'pages/$pageId',
    body: {'properties': ?properties, 'in_trash': ?inTrash},
  );

  /// The page, or null when it was deleted for good (or never shared).
  Future<Map<String, Object?>?> page(String pageId) async {
    try {
      return await _send('GET', 'pages/$pageId');
    } on NotionException catch (e) {
      if (e.status == 404) return null;
      rethrow;
    }
  }
}
