import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'ai_error.dart';
import 'ai_tasks.dart';

/// Sends a prompt to an AI service and returns its raw text reply.
abstract interface class AiClient {
  Future<String> complete(AiPrompt prompt);
}

const _timeout = Duration(minutes: 4);

Future<http.Response> _post(
  http.Client client,
  Uri url,
  Map<String, String> headers,
  Map<String, Object?> body,
) async {
  try {
    return await client
        .post(url, headers: headers, body: jsonEncode(body))
        .timeout(_timeout);
  } on TimeoutException {
    throw const AiException(AiErrorKind.network, '逾時');
  } on SocketException catch (e) {
    throw AiException(AiErrorKind.network, e.message);
  } on http.ClientException catch (e) {
    throw AiException(AiErrorKind.network, e.message);
  }
}

AiException _httpError(http.Response r) {
  String detail;
  try {
    final json = jsonDecode(utf8.decode(r.bodyBytes));
    final error = json is Map ? json['error'] : null;
    detail = error is Map
        ? '${error['message'] ?? error['type'] ?? ''}'
        : '$error';
  } on FormatException {
    detail = 'HTTP ${r.statusCode}';
  }
  final kind = switch (r.statusCode) {
    401 || 403 => AiErrorKind.auth,
    429 => AiErrorKind.rateLimit,
    529 || 503 || 502 || 500 => AiErrorKind.overloaded,
    _ => AiErrorKind.badRequest,
  };
  return AiException(kind, detail);
}

/// Anthropic Messages API with the user's own key.
class ClaudeClient implements AiClient {
  ClaudeClient({
    required this.httpClient,
    required this.apiKey,
    required this.model,
    Uri? endpoint,
  }) : endpoint =
           endpoint ?? Uri.parse('https://api.anthropic.com/v1/messages');

  final http.Client httpClient;
  final String apiKey;
  final String model;
  final Uri endpoint;

  /// Haiku has no server-side refusal fallback.
  bool get _fallbacks => !model.contains('haiku');

  @override
  Future<String> complete(AiPrompt prompt) async {
    final r = await _post(
      httpClient,
      endpoint,
      {
        'content-type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2026-10-21',
        if (_fallbacks) 'anthropic-beta': 'server-side-fallback-2026-07-01',
      },
      {
        'model': model,
        'max_tokens': 16000,
        'system': prompt.system,
        'messages': [
          {'role': 'user', 'content': prompt.user},
        ],
        'output_config': {
          'effort': 'medium',
          'format': {'type': 'json_schema', 'schema': prompt.schema},
        },
        if (_fallbacks) 'fallbacks': 'default',
      },
    );
    if (r.statusCode != 200) throw _httpError(r);

    final json = jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, Object?>;
    switch (json['stop_reason']) {
      case 'refusal':
        throw const AiException(AiErrorKind.refusal);
      case 'max_tokens':
        throw const AiException(AiErrorKind.truncated);
    }
    final text = [
      for (final block in (json['content'] as List? ?? const []))
        if (block is Map && block['type'] == 'text') block['text'] as String,
    ].join();
    if (text.trim().isEmpty) throw const AiException(AiErrorKind.badResponse);
    return text;
  }
}

/// Any `/chat/completions` endpoint: OpenAI, Gemini, OpenRouter, Ollama…
class OpenAiCompatibleClient implements AiClient {
  OpenAiCompatibleClient({
    required this.httpClient,
    required this.baseUrl,
    required this.apiKey,
    required this.model,
  });

  final http.Client httpClient;
  final String baseUrl;
  final String apiKey;
  final String model;

  Uri get _url =>
      Uri.parse('${baseUrl.replaceAll(RegExp(r'/+$'), '')}/chat/completions');

  @override
  Future<String> complete(AiPrompt prompt) async {
    Future<http.Response> send({required bool jsonMode}) => _post(
      httpClient,
      _url,
      {
        'content-type': 'application/json',
        if (apiKey.isNotEmpty) 'authorization': 'Bearer $apiKey',
      },
      {
        'model': model,
        'messages': [
          {'role': 'system', 'content': prompt.system},
          {'role': 'user', 'content': prompt.user},
        ],
        if (jsonMode) 'response_format': {'type': 'json_object'},
      },
    );

    var r = await send(jsonMode: true);
    // Some servers don't support JSON mode; the parser copes without it.
    if (r.statusCode == 400) r = await send(jsonMode: false);
    if (r.statusCode != 200) throw _httpError(r);

    final json = jsonDecode(utf8.decode(r.bodyBytes));
    final choice = json is Map && json['choices'] is List
        ? (json['choices'] as List).firstOrNull
        : null;
    final message = choice is Map ? choice['message'] : null;
    final content = message is Map ? message['content'] : null;
    if (choice is Map && choice['finish_reason'] == 'length') {
      throw const AiException(AiErrorKind.truncated);
    }
    if (content is! String || content.trim().isEmpty) {
      throw const AiException(AiErrorKind.badResponse);
    }
    return content;
  }
}

/// Placeholder for the paid plan, where the app's own server will call
/// Claude.
class HostedClient implements AiClient {
  const HostedClient();

  @override
  Future<String> complete(AiPrompt prompt) =>
      Future.error(const AiException(AiErrorKind.unavailable));
}
