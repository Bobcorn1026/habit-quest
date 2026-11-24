import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/habit_repository.dart';
import '../../domain/habit.dart';
import '../../game/stacking.dart';
import '../pixel/pixel.dart';
import 'pixel_controls.dart';
import 'mentor_tips.dart';
import 'pixel_page.dart';

/// Collects one habit to build or to break.
class HabitForm extends ConsumerStatefulWidget {
  const HabitForm({
    super.key,
    required this.kind,
    this.initial,
    this.warning,
    this.anchorChoices,
  });

  final HabitKind kind;

  /// Set when editing an existing habit.
  final Habit? initial;

  /// Shown above the submit button, e.g. the price of an edit.
  final String? warning;

  /// Quests that can be picked for 「接在…之後」. Null hides that field
  /// (quit habits, onboarding); empty still allows a typed cue.
  final List<AnchorChoice>? anchorChoices;

  static Future<HabitDraft?> show(
    BuildContext context,
    HabitKind kind, {
    Habit? initial,
    String? warning,
    List<AnchorChoice>? anchorChoices,
  }) => showPixelSheet<HabitDraft>(
    context,
    builder: (_) => HabitForm(
      kind: kind,
      initial: initial,
      warning: warning,
      anchorChoices: anchorChoices,
    ),
  );

  @override
  ConsumerState<HabitForm> createState() => _HabitFormState();
}

class _HabitFormState extends ConsumerState<HabitForm> {
  final _name = TextEditingController();
  final _amount = TextEditingController(text: '20');
  final _unit = TextEditingController(text: '分鐘');
  final _intention = TextEditingController();
  final _cue = TextEditingController();
  int? _anchorId;
  bool _measured = true;
  int _times = 7;
  String? _error;

  bool get _build => widget.kind == HabitKind.build;
  bool get _showAnchor => _build && widget.anchorChoices != null;

  @override
  void initState() {
    super.initState();
    if (_showAnchor) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showMentorTip(context, ref, MentorTip.stacking);
      });
    }
    final h = widget.initial;
    if (h == null) return;
    // An anchor that is no longer on offer (archived) counts as cleared.
    if (widget.anchorChoices?.any((c) => c.habitId == h.anchorHabitId) ==
        true) {
      _anchorId = h.anchorHabitId;
    }
    _cue.text = h.anchorText ?? '';
    _name.text = h.name;
    _intention.text = h.intention ?? '';
    _times = h.timesPerWeek.clamp(1, 7);
    _measured = h.hasAmount;
    if (h.hasAmount) {
      _amount.text = formatAmount(h.target!);
      _unit.text = h.unit ?? '';
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _amount, _unit, _intention, _cue]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = '請輸入習慣名稱');
      return;
    }
    double? target;
    if (_build && _measured) {
      target = double.tryParse(_amount.text.trim());
      if (target == null || target <= 0) {
        setState(() => _error = '目標數量要是大於 0 的數字');
        return;
      }
    }
    final intention = _intention.text.trim();
    final cue = _cue.text.trim();
    Navigator.pop(
      context,
      HabitDraft(
        kind: widget.kind,
        name: name,
        unit: _build && _measured ? _unit.text.trim() : null,
        target: target,
        timesPerWeek: _build ? _times : 7,
        intention: intention.isEmpty ? null : intention,
        anchorHabitId: _showAnchor ? _anchorId : null,
        anchorText: _showAnchor && _anchorId == null && cue.isNotEmpty
            ? cue
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(_build ? '想養成的習慣' : '想戒掉的習慣', style: text.titleLarge),
        const SizedBox(height: 10),
        PixelTextField(
          controller: _name,
          autofocus: widget.initial == null,
          hint: _build ? '例如：讀英文、運動、早睡' : '例如：十一點後滑手機、喝含糖飲料',
        ),
        if (_build) ...[
          const SizedBox(height: 12),
          PixelSegments<bool>(
            values: const [true, false],
            selected: _measured,
            label: (m) => m ? '有數量' : '只要打勾',
            onChanged: (m) => setState(() => _measured = m),
          ),
          if (_measured) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: 96,
                  child: PixelTextField(
                    controller: _amount,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: PixelTextField(controller: _unit, hint: '單位'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final u in const ['分鐘', '頁', '次', '公里', '杯'])
                  PixelButton(
                    tone: PixelButtonTone.quiet,
                    onPressed: () => setState(() => _unit.text = u),
                    child: Text(u),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Text('頻率（一週內哪幾天做都可以）', style: text.bodySmall),
          const SizedBox(height: 6),
          PixelStepper(
            value: _times,
            min: 1,
            max: 7,
            label: (t) => t == 7 ? '每天' : '每週 $t 次',
            onChanged: (t) => setState(() => _times = t),
          ),
        ],
        const SizedBox(height: 12),
        PixelTextField(
          controller: _intention,
          hint: _build ? '何時何地做？例如：晚餐後在書桌前（選填）' : '想做的時候改做什麼？（選填）',
        ),
        if (_showAnchor) ...[
          const SizedBox(height: 12),
          Text('接在…之後（選填）', style: text.bodySmall),
          const SizedBox(height: 6),
          PixelTextField(
            controller: _cue,
            hint: '例如：刷完牙、吃完午餐',
            onChanged: (v) {
              if (v.isNotEmpty && _anchorId != null) {
                setState(() => _anchorId = null);
              }
            },
          ),
          if (widget.anchorChoices!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in widget.anchorChoices!)
                  PixelButton(
                    tone: c.habitId == _anchorId
                        ? PixelButtonTone.gold
                        : PixelButtonTone.quiet,
                    onPressed: () => setState(() {
                      if (_anchorId == c.habitId) {
                        _anchorId = null;
                      } else {
                        _anchorId = c.habitId;
                        _cue.clear();
                      }
                    }),
                    child: Text(c.title),
                  ),
              ],
            ),
          ],
        ],
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(
            _error!,
            style: text.bodySmall?.copyWith(color: PixelPalette.red),
          ),
        ],
        if (widget.warning case final warning?) ...[
          const SizedBox(height: 12),
          PixelFrame(
            style: PixelFrameStyle.seal,
            child: Row(
              children: [
                const PixelSpriteView(PixelIcons.skull),
                const SizedBox(width: 8),
                Expanded(child: Text(warning, style: text.bodySmall)),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        PixelButton(
          expand: true,
          tone: widget.initial == null
              ? PixelButtonTone.gold
              : PixelButtonTone.danger,
          onPressed: _submit,
          child: Text(widget.initial == null ? '加入' : '付出代價並修改'),
        ),
      ],
    );
  }
}

/// A habit draft in a list, with a remove button.
class HabitDraftTile extends StatelessWidget {
  const HabitDraftTile({
    super.key,
    required this.draft,
    required this.onRemove,
  });

  final HabitDraft draft;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final detail = [
      if (draft.target != null)
        '${formatAmount(draft.target!)} ${draft.unit ?? ''}'.trim(),
      if (draft.kind == HabitKind.build)
        draft.timesPerWeek >= 7 ? '每天' : '每週 ${draft.timesPerWeek} 次',
      if (draft.intention != null) draft.intention!,
    ].join('・');
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: PixelFrame(
        style: draft.kind == HabitKind.quit
            ? PixelFrameStyle.seal
            : PixelFrameStyle.panel,
        child: Row(
          children: [
            PixelSpriteView(
              draft.kind == HabitKind.quit
                  ? PixelIcons.seal
                  : PixelIcons.scroll,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(draft.name, style: text.bodyMedium),
                  if (detail.isNotEmpty) Text(detail, style: text.bodySmall),
                ],
              ),
            ),
            PixelButton(
              tone: PixelButtonTone.quiet,
              onPressed: onRemove,
              child: const Text('移除'),
            ),
          ],
        ),
      ),
    );
  }
}
