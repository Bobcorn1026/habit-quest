import 'ai_client.dart';
import 'ai_error.dart';
import 'ai_tasks.dart';
import 'prompts.dart';
import 'response_parser.dart';

/// Asks [client] and parses the reply, with one automatic repair round
/// before giving up with an [AiException].
Future<T> completeWithRepair<T>(
  AiClient client,
  AiPrompt prompt,
  ParseOutcome<T> Function(String raw) parse,
) async {
  var outcome = parse(await client.complete(prompt));
  if (outcome case ParseFailed(:final problems)) {
    final repaired = AiPrompt(
      requestId: prompt.requestId,
      system: prompt.system,
      user:
          '${prompt.user}\n\n'
          '${PromptBuilder.repair(prompt.requestId, problems)}',
      schema: prompt.schema,
    );
    outcome = parse(await client.complete(repaired));
  }
  return switch (outcome) {
    Parsed(:final value) => value,
    ParseFailed(:final problems) => throw AiException(
      AiErrorKind.badResponse,
      problems.join('；'),
    ),
  };
}
