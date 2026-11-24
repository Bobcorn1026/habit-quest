import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ai/ai_config.dart';
import '../../../ai/ai_tasks.dart';
import '../../../ai/prompts.dart';
import '../../../ai/response_parser.dart';
import '../../../ai/template_writer.dart';
import '../../../app/adventure_service.dart';
import '../../../app/ai_providers.dart';
import '../../../app/ai_runner.dart';
import '../../../app/demo_seed.dart';
import '../../../app/local_profile.dart';
import '../../../app/providers.dart';
import '../../../data/habit_repository.dart';
import '../../../domain/habit.dart';
import '../../../domain/quest_rank.dart';
import '../../pixel/pixel.dart';
import '../../widgets/habit_form.dart';
import '../../widgets/mentor.dart';
import '../../widgets/pixel_controls.dart';
import '../../widgets/pixel_page.dart';
import '../settings/settings_screen.dart';
import 'forged_quest_tile.dart';

enum _Step { greet, identity, quests, bard, forge, forged }

/// First run, told as a visit to the adventurers' guild: 莉娜 at the counter
/// registers the hero, takes their first commissions, and has the bard
/// forge them into quests.
class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  var _step = _Step.greet;
  var _lines = _linesFor(_Step.greet, '');
  var _linesDone = false;
  final _name = TextEditingController();
  final _identity = TextEditingController();
  final _drafts = <HabitDraft>[];
  ForgeResult? _forged;
  bool _busy = false;

  String get _hero => _name.text.trim();

  static List<String> _linesFor(_Step step, String name) => switch (step) {
    _Step.greet => const [
      '……啊，是新面孔！歡迎來到王都邊境的冒險者公會。',
      '我是櫃檯的莉娜。呼啊——抱歉，今天的委託特別多。',
      '想成為冒險者，得先在名冊上登記。請在這裡寫下你的名字。',
    ],
    _Step.identity => [
      '「$name」……好名字，我記下了。',
      '公會還想知道一件事：你想成為什麼樣的人？',
      '像是「持續學習的人」「身體強壯的人」。比起「我要做什麼」，「我是誰」更能讓人走得長久喔。',
    ],
    _Step.quests => const [
      '接著是委託。公會的委託有兩種。',
      '一種是「任務」：你想養成的習慣。完成就能拿到經驗值，連續完成還有加成。',
      '另一種是「封印」：你想戒掉的壞習慣。它們會化成魔物被封在印記裡，你得每天守住。',
      '先從一件任務開始吧。越小越好，每天兩分鐘也行——重要的是每天出現。',
      '對了，新人一次最多只能接 2 件委託。升上 Rank 之後，就能接更多。',
    ],
    _Step.bard => const [
      '最後一件事。公會有位吟遊詩人，會把你的委託寫成任務和故事，每週寫一章。',
      '你想怎麼請他寫？之後也能在設定裡改。',
    ],
    _Step.forge => const ['委託書準備好了。請吟遊詩人來鍛造吧！'],
    _Step.forged => ['完成了！這些就是你的委託書。', '名字不滿意的話，點一下就能改。準備好了就出發吧，$name！'],
  };

  @override
  void dispose() {
    _name.dispose();
    _identity.dispose();
    super.dispose();
  }

  void _go(_Step step) => setState(() {
    _step = step;
    _lines = _linesFor(step, _hero);
    _linesDone = false;
  });

  /// 莉娜 reacts without hiding what is on the counter.
  void _say(String line) => setState(() => _lines = [line]);

  int get _limit =>
      ref.read(gameRulesProvider).progression.commissionLimit(QuestRank.f);

  Future<void> _addHabit(HabitKind kind) async {
    final draft = await HabitForm.show(context, kind);
    if (draft == null) return;
    setState(() {
      _drafts.add(draft);
      _forged = null;
    });
    final full = _drafts.length >= _limit;
    _say(
      kind == HabitKind.build
          ? '「${draft.name}」，記下了！${full ? '新人的委託就先到這裡吧。' : '還有想做的事，或想封印的魔物嗎？'}'
          : '「${draft.name}」……這隻魔物就交給你封印了。${full ? '新人的委託就先到這裡吧。' : '還有嗎？'}',
    );
  }

  Future<void> _forge() async {
    setState(() => _busy = true);
    final service = ref.read(adventureServiceProvider);
    final config = await ref.read(settingsRepoProvider).storyConfig();
    final request = await service.forgeRequest(
      heroName: _hero,
      identity: _identity.text.trim().isEmpty ? null : _identity.text.trim(),
      drafts: _drafts,
      config: config,
      withPrologue: true,
    );
    if (!mounted) return;
    final result = await runAiTask<ForgeResult>(
      context,
      ref,
      title: '鍛造任務',
      prompt: PromptBuilder.forge(request),
      parse: (raw) => parseForge(raw, request),
      template: () => TemplateWriter.forge(request),
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (result != null) _forged = result;
    });
    if (result != null) _go(_Step.forged);
  }

  Future<void> _begin() async {
    setState(() => _busy = true);
    await ref
        .read(adventureServiceProvider)
        .begin(
          heroName: _hero,
          identity: _identity.text.trim().isEmpty
              ? null
              : _identity.text.trim(),
          drafts: _drafts,
          forged: _forged!,
        );
    // RootGate swaps to the main tabs once `onboarded` flips.
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _step == _Step.greet,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_busy) _go(_Step.values[_step.index - 1]);
      },
      child: Scaffold(
        body: PixelBackdrop(
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        children: [
                          if (_step == _Step.greet) ...[
                            if (kDebugMode) _demoButton(),
                            const SizedBox(height: 24),
                            Center(
                              child: Text(
                                '勇者日課',
                                style: Theme.of(context).textTheme.displaySmall,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Center(
                              child: Text(
                                '「每天進步 1%，一年後你會強大 37 倍。」',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                          if (_linesDone) ..._counter(context),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: MentorBox(
                        lines: _lines,
                        onDone: () => setState(() => _linesDone = true),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _demoButton() => Align(
    alignment: Alignment.centerRight,
    child: PixelButton(
      tone: PixelButtonTone.quiet,
      // In one transaction, so that what watches the database (the week's
      // price level, the board) first sees the finished adventurer.
      onPressed: () => ref
          .read(databaseProvider)
          .transaction(
            () => seedDemo(
              adventurers: ref.read(adventurerRepoProvider),
              habits: ref.read(habitRepoProvider),
              checkIns: ref.read(checkInRepoProvider),
              story: ref.read(storyRepoProvider),
              settings: ref.read(settingsRepoProvider),
              rules: ref.read(gameRulesProvider),
              today: ref.read(todayProvider),
              heroName: ref.read(localProfileProvider).heroName,
              identity: ref.read(localProfileProvider).identity,
            ),
          ),
      child: const Text('載入示範資料（開發用）'),
    ),
  );

  /// What lies on the counter for the current step.
  List<Widget> _counter(BuildContext context) {
    final text = Theme.of(context).textTheme;
    Widget primary(String label, VoidCallback? onPressed) => PixelButton(
      expand: true,
      onPressed: _busy ? null : onPressed,
      child: Text(label),
    );
    Widget quiet(String label, VoidCallback onPressed) => PixelButton(
      expand: true,
      tone: PixelButtonTone.quiet,
      onPressed: _busy ? null : onPressed,
      child: Text(label),
    );

    switch (_step) {
      case _Step.greet:
        return [
          PixelFrame(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const PixelSpriteView(PixelIcons.quill),
                    const SizedBox(width: 8),
                    Text(
                      '冒險者名冊',
                      style: text.titleLarge?.copyWith(
                        color: PixelPalette.outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                PixelTextField(
                  controller: _name,
                  hint: '你的名字',
                  autofocus: true,
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          primary('簽名', _hero.isEmpty ? null : () => _go(_Step.identity)),
        ];
      case _Step.identity:
        return [
          PixelFrame(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '我想成為……',
                  style: text.bodyMedium?.copyWith(color: PixelPalette.outline),
                ),
                const SizedBox(height: 8),
                PixelTextField(controller: _identity, hint: '例如：持續學習的人、身體強壯的人'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          primary('就這樣寫', () => _go(_Step.quests)),
          const SizedBox(height: 8),
          quiet('先跳過', () {
            _identity.clear();
            _go(_Step.quests);
          }),
        ];
      case _Step.quests:
        return [
          for (final (i, d) in _drafts.indexed)
            HabitDraftTile(
              draft: d,
              onRemove: () => setState(() {
                _drafts.removeAt(i);
                _forged = null;
              }),
            ),
          Row(
            children: [
              Expanded(
                child: PixelButton(
                  expand: true,
                  onPressed: _drafts.length >= _limit
                      ? null
                      : () => _addHabit(HabitKind.build),
                  child: const Text('＋ 任務'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: PixelButton(
                  expand: true,
                  tone: PixelButtonTone.arcane,
                  onPressed: _drafts.length >= _limit
                      ? null
                      : () => _addHabit(HabitKind.quit),
                  child: const Text('＋ 封印'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_drafts.isEmpty)
            Text('至少要有一件委託，冒險才能開始。', style: text.bodySmall)
          else
            primary('就這些，交給公會', () => _go(_Step.bard)),
        ];
      case _Step.bard:
        final config = ref.watch(aiConfigProvider).value ?? const AiConfig();
        final service = ref.read(aiServiceProvider);
        return [
          for (final mode in [
            AiMode.manual,
            AiMode.claude,
            AiMode.openai,
            AiMode.offline,
          ])
            PixelOption(
              selected: config.mode == mode,
              title: mode.label,
              subtitle: switch (mode) {
                AiMode.manual => '推薦：把咒文貼給 ChatGPT、Claude 等任何 AI，再把回覆貼回來。免費。',
                AiMode.claude => '用你自己的 Anthropic API key 一鍵生成。',
                AiMode.openai => '用你自己的 OpenAI／Gemini 等 API key。',
                _ => '只用內建模板，故事比較單調。',
              },
              onTap: () => service.saveConfig(config.copyWith(mode: mode)),
            ),
          if (config.usesApi) ...[
            PixelButton(
              tone: PixelButtonTone.arcane,
              expand: true,
              onPressed: () => SettingsScreen.open(context),
              child: const Text('設定 API key'),
            ),
            const SizedBox(height: 8),
          ],
          primary('決定了', () => _go(_Step.forge)),
        ];
      case _Step.forge:
        return [
          PixelFrame(
            style: PixelFrameStyle.panel,
            child: Text(
              '吟遊詩人會把 ${_drafts.length} 件委託寫成任務，並寫下你的序章。',
              style: text.bodyMedium,
            ),
          ),
          const SizedBox(height: 12),
          primary(_busy ? '鍛造中…' : '請吟遊詩人鍛造', _forge),
        ];
      case _Step.forged:
        final forged = _forged!;
        return [
          for (final h in AdventureService.forgeHabits(_drafts))
            if (forged.questFor(h.key) case final q?)
              ForgedQuestTile(
                habit: h,
                quest: q,
                onEdited: (edited) => setState(() {
                  _forged = ForgeResult(
                    quests: [
                      for (final x in forged.quests)
                        x.key == edited.key ? edited : x,
                    ],
                    world: forged.world,
                    prologue: forged.prologue,
                  );
                }),
              ),
          if (forged.prologue case final p?) ...[
            PixelHeading('序章・${p.title}', icon: PixelIcons.book),
            PixelFrame(child: Text(p.body)),
          ],
          const SizedBox(height: 12),
          primary('踏上冒險', _begin),
          const SizedBox(height: 8),
          quiet('不滿意？重新鍛造', _forge),
        ];
    }
  }
}
