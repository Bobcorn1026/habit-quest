import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/bank_service.dart';
import '../../../app/casino_service.dart';
import '../../../app/focus_service.dart';
import '../../../app/price_service.dart';
import '../../../app/providers.dart';
import '../../../domain/casino.dart';
import '../../pixel/pixel.dart';
import '../bank/bank_screen.dart';
import '../casino/casino_screen.dart';
import '../focus/focus_format.dart';
import '../focus/focus_screen.dart';
import '../shop/shop_screen.dart';

/// The town tab: the training ground, the guild shop and inn, the bank and
/// the casino.
class TownScreen extends ConsumerWidget {
  const TownScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final gold = ref.watch(goldProvider).value ?? 0;
    final percent = ref.watch(priceLevelProvider).value ?? 100;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        PixelFrame(
          style: PixelFrameStyle.ornate,
          child: Row(
            children: [
              const PixelSpriteView(PixelIcons.coin),
              const SizedBox(width: 8),
              Expanded(child: Text('$gold 金幣', style: text.titleLarge)),
              Text('本週物價 ${formatPriceLevel(percent)}', style: text.bodyMedium),
            ],
          ),
        ),
        const SizedBox(height: 12),
        BuildingCard(
          art: PixelBuildings.dojo,
          name: '修練場',
          status: _dojoStatus(ref),
          onTap: () => FocusScreen.open(context),
        ),
        BuildingCard(
          art: PixelBuildings.guild,
          name: '公會商店・旅店',
          status: '頭像、稱號框、木紋，還有休息日',
          onTap: () => ShopScreen.open(context),
        ),
        BuildingCard(
          art: PixelBuildings.bank,
          name: '銀行',
          status: _bankStatus(ref),
          onTap: () => BankScreen.open(context),
        ),
        BuildingCard(
          art: PixelBuildings.casino,
          name: '賭場',
          status: _casinoStatus(ref),
          onTap: () => CasinoScreen.open(context),
        ),
      ],
    );
  }

  String _casinoStatus(WidgetRef ref) {
    final view = ref.watch(casinoViewProvider).value;
    return switch (view?.closed) {
      CasinoClosed.noBank => '銀行開戶後開張',
      CasinoClosed.emptyPool => '這週休息，下個月補充獎池後再開',
      _ when view == null || view.week == null => '用金幣抽現實的獎金',
      _ when view.left.isEmpty => '這週的籤抽完了',
      _ =>
        '一抽 ${view.price} 金幣・'
            '${view.count(PrizeTier.top).$1 > 0 ? '大獎還在' : '還剩 ${view.left.length} 張'}',
    };
  }

  String _bankStatus(WidgetRef ref) {
    final view = ref.watch(bankViewProvider).value;
    if (view == null || !view.opened) return '把現實的錢分進各種用途的帳戶';
    if (view.todayMeal == null) return '管理現實的錢';
    return view.claimedToday ? '今天的餐費已經領了' : '今天的餐費還沒領';
  }

  String _dojoStatus(WidgetRef ref) {
    final focus = ref.watch(focusProvider);
    final today = ref.watch(focusLedgerProvider)?.days.lastOrNull;
    if (today == null) return '每天從 -50:00 開始的專注碼表';
    final clock = formatFocusClock(today.endSeconds);
    return switch (focus.phase) {
      FocusPhase.running => '專注中・今天 $clock',
      FocusPhase.resting => '休息中・今天 $clock',
      FocusPhase.idle when today.endSeconds < 0 =>
        '今天還欠 ${owedMinutes(today.endSeconds)} 分鐘',
      FocusPhase.idle => '今天已還清・賺了 ${today.gold} 金幣',
    };
  }
}

/// One building of the town: its art, name and how it stands. Buildings
/// without [onTap] are still being built.
class BuildingCard extends StatelessWidget {
  const BuildingCard({
    super.key,
    required this.art,
    required this.name,
    required this.status,
    this.onTap,
  });

  final PixelSprite art;
  final String name;
  final String status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final open = onTap != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Semantics(
        button: open,
        enabled: open,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Opacity(
            opacity: open ? 1 : 0.55,
            child: PixelFrame(
              style: PixelFrameStyle.panel,
              child: Row(
                children: [
                  PixelSpriteView(art),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: text.bodyLarge),
                        Text(status, style: text.bodySmall),
                      ],
                    ),
                  ),
                  if (open)
                    PixelButton(
                      tone: PixelButtonTone.quiet,
                      onPressed: onTap,
                      child: const Text('進入'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
