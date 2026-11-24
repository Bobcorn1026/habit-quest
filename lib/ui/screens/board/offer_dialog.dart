import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ai/ai_tasks.dart';
import '../../../ai/prompts.dart';
import '../../../ai/response_parser.dart';
import '../../../app/adventure_service.dart';
import '../../../app/ai_runner.dart';
import '../../../app/board.dart';
import '../../../app/offer_texts.dart';
import '../../../app/providers.dart';
import '../../../domain/upgrade_offer.dart';
import '../../../game/promotion.dart';
import '../../pixel/pixel.dart';
import '../../widgets/pixel_controls.dart';

enum OfferAnswer { accept, decline, retire }

/// What the player decided, with the quest text as they left it.
typedef OfferDecision = ({
  OfferAnswer answer,
  String title,
  String subtitle,
  double? target,
});

/// 莉娜 invites the player to take a quest to its next tier. The bard can
/// propose the new quest; the player has the last word on every field.
class OfferDialog extends ConsumerStatefulWidget {
  const OfferDialog({super.key, required this.entry, required this.offer});

  final BoardEntry entry;
  final UpgradeOffer offer;

  static Future<OfferDecision?> show(BuildContext context, BoardEntry entry) =>
      showPixelDialog<OfferDecision>(
        context,
        builder: (_) => OfferDialog(entry: entry, offer: entry.offer!),
      );

  @override
  ConsumerState<OfferDialog> createState() => _OfferDialogState();
}

class _OfferDialogState extends ConsumerState<OfferDialog> {
  late final _title = TextEditingController(text: widget.offer.proposedTitle);
  late final _subtitle = TextEditingController(
    text: widget.offer.proposedSubtitle,
  );
  late final _target = TextEditingController(
    text: widget.offer.proposedTarget == null
        ? ''
        : formatAmount(widget.offer.proposedTarget!),
  );
  late String _npcLine = widget.offer.npcLine;
  bool _asking = false;

  bool get _seal => widget.offer.kind == OfferKind.sealMastery;

  @override
  void dispose() {
    _title.dispose();
    _subtitle.dispose();
    _target.dispose();
    super.dispose();
  }

  Future<void> _askBard() async {
    setState(() => _asking = true);
    final rules = ref.read(gameRulesProvider).promotion;
    final quest = widget.entry.active.quest;
    final current = quest.target;
    final request = UpgradeRequest(
      requestId: newRequestId(),
      config: await ref.read(settingsRepoProvider).storyConfig(),
      world: await ref.read(adventureServiceProvider).world(),
      reason: _seal ? UpgradeReason.sealMastery : UpgradeReason.surpass,
      questTitle: quest.title,
      questSubtitle: quest.subtitle,
      habitName: widget.entry.habit.name,
      unit: widget.entry.habit.unit,
      currentTarget: current,
      suggestedTarget: current == null
          ? null
          : suggestedUpgradeTarget(current, rules),
      minTarget: current == null ? null : current * rules.upgradeMinFactor,
      maxTarget: current == null ? null : current * rules.upgradeMaxFactor,
      nextRank: quest.rank.next,
    );
    if (!mounted) return;
    final proposal = await runAiTask<UpgradeProposal>(
      context,
      ref,
      title: '晉階提案',
      prompt: PromptBuilder.upgrade(request),
      parse: (raw) => parseUpgrade(raw, request),
      template: () {
        final t = offerTemplate(widget.offer.kind, quest);
        return UpgradeProposal(
          title: t.title,
          subtitle: t.subtitle,
          npcLine: t.npcLine,
          target: request.suggestedTarget,
        );
      },
    );
    if (!mounted) return;
    setState(() {
      _asking = false;
      if (proposal == null) return;
      _title.text = proposal.title;
      _subtitle.text = proposal.subtitle;
      if (proposal.npcLine.isNotEmpty) _npcLine = proposal.npcLine;
      if (proposal.target case final t?) _target.text = formatAmount(t);
    });
  }

  void _answer(OfferAnswer answer) {
    final target = double.tryParse(_target.text.trim());
    Navigator.pop<OfferDecision>(context, (
      answer: answer,
      title: _title.text.trim().isEmpty
          ? widget.offer.proposedTitle
          : _title.text.trim(),
      subtitle: _subtitle.text.trim(),
      target: target != null && target > 0 ? target : null,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final quest = widget.entry.active.quest;
    final unit = widget.entry.habit.unit ?? '';
    final from = quest.target;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const PixelSpriteView(PixelPortraits.mentor),
            const SizedBox(width: 12),
            Expanded(child: Text('晉階邀請', style: text.titleLarge)),
            RankBadge(quest.rank),
            const SizedBox(width: 4),
            Text('→', style: text.bodySmall),
            const SizedBox(width: 4),
            RankBadge(quest.rank.next),
          ],
        ),
        const SizedBox(height: 10),
        Text(_npcLine, style: text.bodyMedium),
        const SizedBox(height: 12),
        Text('新的任務名', style: text.bodySmall),
        const SizedBox(height: 4),
        PixelTextField(controller: _title),
        const SizedBox(height: 8),
        Text('副標', style: text.bodySmall),
        const SizedBox(height: 4),
        PixelTextField(controller: _subtitle),
        if (from != null && !_seal) ...[
          const SizedBox(height: 8),
          Text('每日目標（原本 ${formatAmount(from)} $unit）', style: text.bodySmall),
          const SizedBox(height: 4),
          PixelTextField(
            controller: _target,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
        const SizedBox(height: 10),
        PixelButton(
          expand: true,
          tone: PixelButtonTone.arcane,
          onPressed: _asking ? null : _askBard,
          child: Text(_asking ? '吟遊詩人構思中…' : '請吟遊詩人重新提案'),
        ),
        const SizedBox(height: 8),
        PixelButton(
          expand: true,
          onPressed: () => _answer(OfferAnswer.accept),
          child: Text(_seal ? '收緊封印' : '接受晉階'),
        ),
        if (_seal) ...[
          const SizedBox(height: 8),
          PixelButton(
            expand: true,
            tone: PixelButtonTone.arcane,
            onPressed: () => _answer(OfferAnswer.retire),
            child: const Text('封存為戰利品'),
          ),
        ],
        const SizedBox(height: 8),
        PixelButton(
          expand: true,
          tone: PixelButtonTone.quiet,
          onPressed: () => _answer(OfferAnswer.decline),
          child: const Text('暫時不要'),
        ),
      ],
    );
  }
}
