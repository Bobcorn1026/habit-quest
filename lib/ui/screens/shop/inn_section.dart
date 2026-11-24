import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/game_service.dart';
import '../../../app/price_service.dart';
import '../../../app/providers.dart';
import '../../../game/price_level.dart';
import '../../../core/logical_day.dart';
import '../../../game/period.dart';
import '../../pixel/pixel.dart';
import '../../widgets/pixel_controls.dart';
import 'shop_screen.dart';

String _dayLabel(LogicalDay d) => formatDayLabel(d.month, d.day, d.weekday);

/// The inn at the top of the shop: gold buys a booked rest day.
class InnSection extends ConsumerWidget {
  const InnSection({super.key});

  Future<void> _book(BuildContext context, WidgetRef ref) async {
    final day = await showPixelSheet<LogicalDay>(
      context,
      builder: (_) => const _BookingSheet(),
    );
    if (day == null || !context.mounted) return;
    final result = await ref.read(gameServiceProvider).bookInn(day);
    if (!context.mounted) return;
    showPixelToast(context, switch (result) {
      InnResult.booked => '已預約 ${_dayLabel(day)} 的住宿，那天好好休息',
      InnResult.notFuture => '只能預約明天以後的日子',
      InnResult.tooFar => '只能預約一週內的日子',
      InnResult.weekFull => '那一週的房間已經客滿了',
      InnResult.alreadyBooked => '那天已經預約過了',
      InnResult.notEnoughGold => '金幣不夠……再多完成幾件委託吧',
    }, icon: result == InnResult.booked ? PixelIcons.coin : PixelIcons.skull);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final rules = ref.watch(gameRulesProvider).progression;
    final price = inflate(
      rules.innPrice,
      ref.watch(priceLevelProvider).value ?? 100,
    );
    final today = ref.watch(todayProvider);
    final upcoming = [
      for (final d in ref.watch(restDaysProvider).value ?? const <LogicalDay>{})
        if (d.isAfter(today)) d,
    ]..sort();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PixelHeading('旅店', icon: PixelIcons.chest),
        ShopRow(
          preview: const PixelSpriteView(PixelIcons.potion),
          name: '住宿一晚（休息日）',
          detail: '$price 金幣',
          action: PixelButton(
            onPressed: () => _book(context, ref),
            child: const Text('預約'),
          ),
        ),
        for (final d in upcoming)
          ShopRow(
            preview: const PixelSpriteView(PixelIcons.star),
            name: _dayLabel(d),
            detail: '已預約：不回報也不會負傷',
            action: PixelButton(
              tone: PixelButtonTone.quiet,
              onPressed: () async {
                final refund = await ref.read(gameServiceProvider).cancelInn(d);
                if (refund != null && context.mounted) {
                  showPixelToast(
                    context,
                    '取消了 ${_dayLabel(d)} 的住宿，退回 $refund 金幣',
                    icon: PixelIcons.coin,
                  );
                }
              },
              child: const Text('取消'),
            ),
          ),
        if (upcoming.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '每週最多 ${rules.innPerWeek} 晚，可預約明天起 ${rules.innMaxAheadDays} 天內。',
              style: text.bodySmall,
            ),
          ),
      ],
    );
  }
}

class _BookingSheet extends ConsumerWidget {
  const _BookingSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final rules = ref.watch(gameRulesProvider);
    final p = rules.progression;
    final today = ref.watch(todayProvider);
    final gold = ref.watch(goldProvider).value ?? 0;
    final price = inflate(
      p.innPrice,
      ref.watch(priceLevelProvider).value ?? 100,
    );
    final booked = ref.watch(restDaysProvider).value ?? const <LogicalDay>{};
    final weeks = PeriodCalendar.weeks(weekStartsOn: rules.weekStartsOn);

    String? reason(LogicalDay d) {
      if (booked.contains(d)) return '已預約';
      if (booked.where(weeks.periodOf(d).contains).length >= p.innPerWeek) {
        return '本週客滿';
      }
      if (gold < price) return '金幣不夠';
      return null;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('預約住宿', style: text.titleLarge),
        Text('$price 金幣一晚。那天不回報也不會負傷，取消可全額退款。', style: text.bodySmall),
        const SizedBox(height: 8),
        for (var i = 1; i <= p.innMaxAheadDays; i++)
          _DayRow(day: today.addDays(i), reason: reason(today.addDays(i))),
      ],
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({required this.day, required this.reason});

  final LogicalDay day;
  final String? reason;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(_dayLabel(day), style: text.bodyMedium)),
          if (reason != null) ...[
            Text(reason!, style: text.bodySmall),
            const SizedBox(width: 8),
          ],
          PixelButton(
            tone: PixelButtonTone.quiet,
            onPressed: reason == null
                ? () => Navigator.of(context).pop(day)
                : null,
            child: const Text('預約'),
          ),
        ],
      ),
    );
  }
}
