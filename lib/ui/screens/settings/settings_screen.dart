import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ai/ai_config.dart';
import '../../../ai/ai_error.dart';
import '../../../ai/ai_tasks.dart';
import '../../../ai/secret_store.dart';
import '../../../app/ai_providers.dart';
import '../../../app/providers.dart';
import '../../../app/reminders.dart';
import '../../../data/settings_repository.dart';
import '../../../domain/story_config.dart';
import '../../pixel/pixel.dart';
import '../../widgets/pixel_controls.dart';
import '../../widgets/pixel_page.dart';
import '../../widgets/pixel_pickers.dart';
import '../dev/kit_gallery.dart';
import 'data_section.dart';
import 'debug_clock.dart';
import 'notion_section.dart';
import 'secret_key_field.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const SettingsScreen()));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ai = ref.watch(aiConfigProvider).value ?? const AiConfig();
    final story = ref.watch(storyConfigProvider).value ?? const StoryConfig();
    final pixelFont = ref.watch(storyPixelFontProvider).value ?? true;
    final reminders =
        ref.watch(reminderSettingsProvider).value ?? const ReminderSettings();
    final service = ref.read(aiServiceProvider);
    final settings = ref.read(settingsRepoProvider);
    final text = Theme.of(context).textTheme;

    return PixelPage(
      title: '設定',
      children: [
        const PixelHeading('AI 吟遊詩人', icon: PixelIcons.quill),
        Text('誰來把你的習慣寫成任務與故事？', style: text.bodySmall),
        const SizedBox(height: 8),
        for (final mode in AiMode.values)
          PixelOption(
            selected: ai.mode == mode,
            enabled: mode != AiMode.hosted,
            title: mode.label,
            subtitle: switch (mode) {
              AiMode.manual => '把咒文貼給任何 AI 聊天，再把回覆貼回來。免費。',
              AiMode.claude => '用你自己的 Anthropic API key，一鍵生成。',
              AiMode.openai => 'OpenAI、Gemini、OpenRouter、本機 Ollama…',
              AiMode.hosted => '即將推出：免設定，由 app 代為生成。',
              AiMode.offline => '只用內建模板，完全不連網。',
            },
            onTap: () => service.saveConfig(ai.copyWith(mode: mode)),
          ),
        if (ai.mode == AiMode.claude) _ClaudeSection(config: ai),
        if (ai.mode == AiMode.openai) _OpenAiSection(config: ai),
        const PixelHeading('故事', icon: PixelIcons.book),
        _Labeled(
          '每章涵蓋',
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PixelStepper(
                value: story.periodDays,
                min: 1,
                max: 28,
                label: (d) => '每章 $d 天',
                onChanged: (d) =>
                    settings.saveStoryConfig(story.copyWith(periodDays: d)),
              ),
              const SizedBox(height: 8),
              PixelSegments<int>(
                values: const [3, 7, 14],
                selected: story.periodDays,
                label: (d) => '$d 天',
                onChanged: (d) =>
                    settings.saveStoryConfig(story.copyWith(periodDays: d)),
              ),
            ],
          ),
        ),
        _Labeled(
          '章末',
          PixelSegments<StoryInteraction>(
            values: StoryInteraction.values,
            selected: story.interaction,
            label: (i) => i == StoryInteraction.choices ? '給抉擇' : '純旁白',
            onChanged: (i) =>
                settings.saveStoryConfig(story.copyWith(interaction: i)),
          ),
        ),
        if (story.interaction == StoryInteraction.choices)
          _Labeled(
            '抉擇數量',
            PixelSegments<int>(
              values: const [2, 3],
              selected: story.choicesPerChapter,
              label: (n) => '$n 個',
              onChanged: (n) => settings.saveStoryConfig(
                story.copyWith(choicesPerChapter: n),
              ),
            ),
          ),
        _Labeled(
          '語氣',
          PixelSegments<StoryTone>(
            values: StoryTone.values,
            selected: story.tone,
            label: (t) => t.label,
            onChanged: (t) => settings.saveStoryConfig(story.copyWith(tone: t)),
          ),
        ),
        _Labeled(
          '世界觀',
          _WorldField(
            initial: story.world,
            onSave: (w) => settings.saveStoryConfig(story.copyWith(world: w)),
          ),
        ),
        _Labeled(
          '故事字體',
          PixelSegments<bool>(
            values: const [true, false],
            selected: pixelFont,
            label: (p) => p ? '像素字' : '系統字（較好讀）',
            onChanged: (p) =>
                settings.write(SettingKeys.storyFont, p ? 'pixel' : 'system'),
          ),
        ),
        const PixelHeading('提醒', icon: PixelIcons.flame),
        _Labeled(
          '每日提醒',
          PixelSegments<bool>(
            values: const [false, true],
            selected: reminders.enabled,
            label: (on) => on ? '開啟' : '關閉',
            onChanged: (on) async {
              if (on &&
                  !await ref
                      .read(reminderSchedulerProvider)
                      .requestPermission()) {
                if (context.mounted) {
                  showPixelToast(
                    context,
                    '沒有通知權限：請到系統設定開啟「勇者日課」的通知',
                    icon: PixelIcons.skull,
                  );
                }
                return;
              }
              await settings.write(
                SettingKeys.reminders,
                reminders.copyWith(enabled: on).toJson(),
              );
            },
          ),
        ),
        if (reminders.enabled)
          _Labeled(
            '提醒時間（當天都回報完就不響）',
            Align(
              alignment: Alignment.centerLeft,
              child: PixelButton(
                tone: PixelButtonTone.gold,
                onPressed: () async {
                  final picked = await pickTime(
                    context,
                    title: '提醒時間',
                    initial: TimeOfDay(
                      hour: reminders.hour,
                      minute: reminders.minute,
                    ),
                  );
                  if (picked == null) return;
                  await settings.write(
                    SettingKeys.reminders,
                    reminders
                        .copyWith(hour: picked.hour, minute: picked.minute)
                        .toJson(),
                  );
                },
                child: Text(
                  '${reminders.hour.toString().padLeft(2, '0')}:'
                  '${reminders.minute.toString().padLeft(2, '0')}',
                ),
              ),
            ),
          ),
        const NotionSection(),
        const DataSection(),
        if (kDebugMode) ...[
          const PixelHeading('開發', icon: PixelIcons.d20),
          PixelButton(
            tone: PixelButtonTone.quiet,
            expand: true,
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const KitGallery())),
            child: const Text('元件展示'),
          ),
          const SizedBox(height: 8),
          PixelButton(
            tone: PixelButtonTone.quiet,
            expand: true,
            onPressed: () async {
              final scheduler = ref.read(reminderSchedulerProvider);
              if (!await scheduler.requestPermission()) return;
              await scheduler.test(const Duration(seconds: 5));
              if (context.mounted) showPixelToast(context, '5 秒後會跳出測試提醒');
            },
            child: const Text('5 秒後測試提醒'),
          ),
          const SizedBox(height: 8),
          const DebugClockControls(),
        ],
      ],
    );
  }
}

class _Labeled extends StatelessWidget {
  const _Labeled(this.label, this.child);
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 6),
        child,
      ],
    ),
  );
}

class _WorldField extends StatefulWidget {
  const _WorldField({required this.initial, required this.onSave});
  final String initial;
  final ValueChanged<String> onSave;

  @override
  State<_WorldField> createState() => _WorldFieldState();
}

class _WorldFieldState extends State<_WorldField> {
  late final _c = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PixelTextField(
    controller: _c,
    hint: '例如：中世紀劍與魔法、蒸汽龐克、東方仙俠',
    textInputAction: TextInputAction.done,
    onSubmitted: (v) {
      widget.onSave(v.trim());
      showPixelToast(context, '世界觀已更新');
    },
  );
}

/// Key entry shared by both API sections.
class _TestButton extends ConsumerStatefulWidget {
  const _TestButton({required this.config});
  final AiConfig config;

  @override
  ConsumerState<_TestButton> createState() => _TestButtonState();
}

class _TestButtonState extends ConsumerState<_TestButton> {
  bool _busy = false;

  Future<void> _test() async {
    setState(() => _busy = true);
    String result;
    try {
      final client = await ref.read(aiServiceProvider).clientFor(widget.config);
      final reply = await client!.complete(
        AiPrompt(
          requestId: newRequestId(),
          system: '你是連線測試助手。',
          user: '只回覆這個 JSON：{"ok": true}',
          schema: const {
            'type': 'object',
            'additionalProperties': false,
            'required': ['ok'],
            'properties': {
              'ok': {'type': 'boolean'},
            },
          },
        ),
      );
      result = reply.contains('true') ? '連線成功！' : '有回應，但內容怪怪的：$reply';
    } on AiException catch (e) {
      result = e.toString();
    }
    if (!mounted) return;
    setState(() => _busy = false);
    showPixelToast(context, result, icon: PixelIcons.d20);
  }

  @override
  Widget build(BuildContext context) => PixelButton(
    tone: PixelButtonTone.arcane,
    expand: true,
    onPressed: _busy ? null : _test,
    child: Text(_busy ? '測試中…' : '測試連線（會用掉極少量額度）'),
  );
}

class _ClaudeSection extends ConsumerWidget {
  const _ClaudeSection({required this.config});
  final AiConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.read(aiServiceProvider);
    return PixelFrame(
      style: PixelFrameStyle.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '到 console.anthropic.com 建立 API key 並儲值。這個 app 每週大約只用一次，'
            '每月通常不到 US\$0.5。',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          const SecretKeyField(secretKey: SecretKeys.claude, hint: 'sk-ant-…'),
          const SizedBox(height: 12),
          for (final (id, label) in kClaudeModels)
            PixelOption(
              selected: config.claudeModel == id,
              title: label,
              onTap: () => service.saveConfig(config.copyWith(claudeModel: id)),
            ),
          _TestButton(config: config),
        ],
      ),
    );
  }
}

class _OpenAiSection extends ConsumerStatefulWidget {
  const _OpenAiSection({required this.config});
  final AiConfig config;

  @override
  ConsumerState<_OpenAiSection> createState() => _OpenAiSectionState();
}

class _OpenAiSectionState extends ConsumerState<_OpenAiSection> {
  late final _url = TextEditingController(text: widget.config.openAiBaseUrl);
  late final _model = TextEditingController(text: widget.config.openAiModel);

  @override
  void dispose() {
    _url.dispose();
    _model.dispose();
    super.dispose();
  }

  Future<void> _save() => ref
      .read(aiServiceProvider)
      .saveConfig(
        widget.config.copyWith(
          openAiBaseUrl: _url.text.trim(),
          openAiModel: _model.text.trim(),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return PixelFrame(
      style: PixelFrameStyle.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('快速選擇', style: text.bodySmall),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (name, url, model) in kOpenAiPresets)
                PixelButton(
                  tone: PixelButtonTone.quiet,
                  onPressed: () {
                    _url.text = url;
                    _model.text = model;
                    _save();
                  },
                  child: Text(name),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text('Base URL', style: text.bodySmall),
          PixelTextField(controller: _url, onSubmitted: (_) => _save()),
          const SizedBox(height: 8),
          Text('模型名稱', style: text.bodySmall),
          PixelTextField(
            controller: _model,
            hint: '例如 gpt-5',
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 8),
          PixelButton(
            tone: PixelButtonTone.quiet,
            expand: true,
            onPressed: () async {
              await _save();
              if (context.mounted) showPixelToast(context, '已儲存');
            },
            child: const Text('儲存網址與模型'),
          ),
          const SizedBox(height: 12),
          const SecretKeyField(
            secretKey: SecretKeys.openai,
            hint: 'API key（本機 Ollama 可留空）',
          ),
          const SizedBox(height: 12),
          _TestButton(config: widget.config),
        ],
      ),
    );
  }
}
