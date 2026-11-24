import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ai/ai_config.dart';
import '../ai/ai_error.dart';
import '../ai/ai_tasks.dart';
import '../ai/complete.dart';
import '../ai/response_parser.dart';
import '../ui/pixel/pixel.dart';
import '../ui/screens/ai/manual_ai_screen.dart';
import '../ui/widgets/pixel_controls.dart';
import 'ai_providers.dart';

enum _Recovery { retry, manual, template }

/// Runs one AI task in whatever mode the player chose, falling back to
/// copy-paste or templates when something goes wrong. Returns null if the
/// player backs out.
Future<T?> runAiTask<T>(
  BuildContext context,
  WidgetRef ref, {
  required String title,
  required AiPrompt prompt,
  required ParseOutcome<T> Function(String raw) parse,
  required T Function() template,
}) async {
  final service = ref.read(aiServiceProvider);
  final config = await service.config();
  if (!context.mounted) return null;

  switch (config.mode) {
    case AiMode.offline:
      return template();
    case AiMode.manual:
      return ManualAiScreen.open<T>(
        context,
        title: title,
        prompt: prompt,
        parse: parse,
      );
    case AiMode.claude || AiMode.openai || AiMode.hosted:
      break;
  }

  while (true) {
    String? failure;
    try {
      final value = await _withProgress(
        context,
        () async => completeWithRepair(
          (await service.clientFor(config))!,
          prompt,
          parse,
        ),
      );
      return value;
    } on AiException catch (e) {
      failure = e.toString();
    }
    if (!context.mounted) return null;
    final choice = await _askRecovery(context, failure);
    if (!context.mounted) return null;
    switch (choice) {
      case _Recovery.retry:
        continue;
      case _Recovery.manual:
        return ManualAiScreen.open<T>(
          context,
          title: title,
          prompt: prompt,
          parse: parse,
        );
      case _Recovery.template:
        return template();
      case null:
        return null;
    }
  }
}

Future<T> _withProgress<T>(
  BuildContext context,
  Future<T> Function() work,
) async {
  final navigator = Navigator.of(context);
  showPixelDialog<void>(
    context,
    dismissible: false,
    builder: (ctx) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const PixelSpriteView(PixelArt.quill),
        const SizedBox(height: 12),
        Text('吟遊詩人正在提筆……', style: Theme.of(ctx).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text('通常需要十幾秒到一分鐘', style: Theme.of(ctx).textTheme.bodySmall),
      ],
    ),
  );
  try {
    return await work();
  } finally {
    navigator.pop();
  }
}

Future<_Recovery?> _askRecovery(BuildContext context, String message) =>
    showPixelDialog<_Recovery>(
      context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const PixelSpriteView(PixelArt.skull),
              const SizedBox(width: 12),
              Expanded(
                child: Text('咒文失效了', style: Theme.of(ctx).textTheme.titleLarge),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(message, style: Theme.of(ctx).textTheme.bodyMedium),
          const SizedBox(height: 16),
          PixelButton(
            expand: true,
            onPressed: () => Navigator.pop(ctx, _Recovery.retry),
            child: const Text('再試一次'),
          ),
          const SizedBox(height: 8),
          PixelButton(
            tone: PixelButtonTone.arcane,
            expand: true,
            onPressed: () => Navigator.pop(ctx, _Recovery.manual),
            child: const Text('改用複製咒文'),
          ),
          const SizedBox(height: 8),
          PixelButton(
            tone: PixelButtonTone.quiet,
            expand: true,
            onPressed: () => Navigator.pop(ctx, _Recovery.template),
            child: const Text('先用內建故事'),
          ),
        ],
      ),
    );
