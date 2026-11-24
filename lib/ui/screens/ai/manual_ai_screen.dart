import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../ai/ai_tasks.dart';
import '../../../ai/prompts.dart';
import '../../../ai/response_parser.dart';
import '../../pixel/pixel.dart';
import '../../widgets/pixel_controls.dart';
import '../../widgets/pixel_page.dart';

/// Copy-paste mode: the player carries the prompt to any chat AI and brings
/// the reply back.
class ManualAiScreen<T> extends StatefulWidget {
  const ManualAiScreen({
    super.key,
    required this.title,
    required this.prompt,
    required this.parse,
  });

  final String title;
  final AiPrompt prompt;
  final ParseOutcome<T> Function(String raw) parse;

  static Future<T?> open<T>(
    BuildContext context, {
    required String title,
    required AiPrompt prompt,
    required ParseOutcome<T> Function(String raw) parse,
  }) => Navigator.of(context).push<T>(
    MaterialPageRoute(
      builder: (_) =>
          ManualAiScreen<T>(title: title, prompt: prompt, parse: parse),
    ),
  );

  @override
  State<ManualAiScreen<T>> createState() => _ManualAiScreenState<T>();
}

class _ManualAiScreenState<T> extends State<ManualAiScreen<T>> {
  final _reply = TextEditingController();
  List<String> _problems = const [];
  bool _showPrompt = false;

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  Future<void> _copy(String text, String done) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) showPixelToast(context, done, icon: PixelIcons.scroll);
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text case final text? when text.isNotEmpty) {
      setState(() => _reply.text = text);
    }
  }

  void _read() {
    switch (widget.parse(_reply.text)) {
      case Parsed(:final value):
        Navigator.pop(context, value);
      case ParseFailed(:final problems):
        setState(() => _problems = problems);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return PixelPage(
      title: widget.title,
      children: [
        const PixelFrame(
          style: PixelFrameStyle.panel,
          child: Text('複製咒文模式：請你常用的 AI（ChatGPT、Claude、Gemini…）幫忙寫，完全免費。'),
        ),
        const PixelHeading('① 複製咒文', icon: PixelIcons.scroll),
        PixelButton(
          expand: true,
          onPressed: () => _copy(widget.prompt.manualText, '咒文已複製'),
          child: const Text('複製咒文'),
        ),
        const SizedBox(height: 8),
        PixelButton(
          tone: PixelButtonTone.quiet,
          expand: true,
          onPressed: () => setState(() => _showPrompt = !_showPrompt),
          child: Text(_showPrompt ? '收起咒文內容' : '看看咒文內容'),
        ),
        if (_showPrompt) ...[
          const SizedBox(height: 8),
          PixelFrame(
            style: PixelFrameStyle.panel,
            child: SelectableText(
              widget.prompt.manualText,
              style: text.bodySmall,
            ),
          ),
        ],
        const PixelHeading('② 貼給 AI 並送出', icon: PixelIcons.quill),
        Text('開一個新的對話，貼上咒文送出。等 AI 回覆完，把它的整段回覆複製起來。', style: text.bodyMedium),
        const PixelHeading('③ 把回覆貼回來', icon: PixelIcons.d20),
        PixelTextField(
          controller: _reply,
          hint: '把 AI 的整段回覆貼在這裡',
          maxLines: 8,
          minLines: 4,
          keyboardType: TextInputType.multiline,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: PixelButton(
                tone: PixelButtonTone.quiet,
                expand: true,
                onPressed: _pasteFromClipboard,
                child: const Text('從剪貼簿貼上'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: PixelButton(
                tone: PixelButtonTone.arcane,
                expand: true,
                onPressed: _read,
                child: const Text('解讀回覆'),
              ),
            ),
          ],
        ),
        if (_problems.isNotEmpty) ...[
          const SizedBox(height: 16),
          PixelFrame(
            style: PixelFrameStyle.seal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('回覆有點問題：', style: text.bodyMedium),
                for (final p in _problems)
                  Text(
                    '・$p',
                    style: text.bodySmall?.copyWith(color: PixelPalette.red),
                  ),
                const SizedBox(height: 8),
                Text(
                  '按下面的按鈕複製「修正咒文」，貼回同一個對話送出，再把新的回覆貼回來。',
                  style: text.bodySmall,
                ),
                const SizedBox(height: 8),
                PixelButton(
                  tone: PixelButtonTone.gold,
                  expand: true,
                  onPressed: () => _copy(
                    PromptBuilder.repair(widget.prompt.requestId, _problems),
                    '修正咒文已複製',
                  ),
                  child: const Text('複製修正咒文'),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
