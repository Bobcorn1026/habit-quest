import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/shop_service.dart';
import '../../../domain/adventurer.dart';
import '../../../game/shop.dart';
import '../../pixel/pixel.dart';
import '../../pixel/texture.dart';
import '../../widgets/mentor_tips.dart';
import '../../widgets/pixel_controls.dart';
import '../../widgets/pixel_page.dart';
import '../../widgets/title_frame.dart';
import 'inn_section.dart';

/// The guild shop: gold buys looks, the guild rank decides what is on sale.
class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const ShopScreen()));

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showMentorTip(context, ref, MentorTip.shop);
      showMentorTip(context, ref, MentorTip.inn);
    });
  }

  Future<void> _buy(ShopItem item) async {
    final result = await ref.read(shopServiceProvider).buy(item);
    if (!mounted) return;
    showPixelToast(context, switch (result) {
      BuyResult.bought => '買下了「${item.name}」，已經換上',
      BuyResult.rankTooLow => '要 ${item.rank.label} 級冒險者才能買',
      BuyResult.notEnoughGold => '金幣不夠……再多完成幾件委託吧',
    }, icon: result == BuyResult.bought ? PixelIcons.coin : PixelIcons.skull);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final gold = ref.watch(goldProvider).value ?? 0;
    final owned = ref.watch(ownedProvider).value ?? const <String>{};
    final equipped = ref.watch(equippedProvider).value ?? const Equipped();
    final hero = ref.watch(adventurerProvider).value;
    final shop = ref.read(shopServiceProvider);

    bool isEquipped(ShopItem item) => switch (item.category) {
      ShopCategory.portrait => hero?.portraitId == item.value,
      ShopCategory.frame => equipped.frame == item.value,
      ShopCategory.wood => equipped.wood == item.value,
    };
    bool freeEquipped(ShopCategory c) => switch (c) {
      ShopCategory.portrait => !kShopItems.any(
        (i) => i.category == c && i.value == hero?.portraitId,
      ),
      ShopCategory.frame => equipped.frame == null,
      ShopCategory.wood => equipped.wood == 'classic',
    };

    return PixelPage(
      title: '公會商店',
      children: [
        PixelFrame(
          style: PixelFrameStyle.panel,
          child: Row(
            children: [
              const PixelSpriteView(PixelIcons.coin),
              const SizedBox(width: 8),
              Text('$gold 金幣', style: text.titleLarge),
              const Spacer(),
              if (hero != null) ...[
                Text('公會 Rank', style: text.bodySmall),
                const SizedBox(width: 6),
                RankBadge(hero.guildRank),
              ],
            ],
          ),
        ),
        const InnSection(),
        for (final category in ShopCategory.values) ...[
          PixelHeading(category.label, icon: PixelIcons.chest),
          ShopRow(
            preview: _preview(category, null, hero),
            name: switch (category) {
              ShopCategory.portrait => '跟著職業',
              ShopCategory.frame => '不加框',
              ShopCategory.wood => '原木',
            },
            detail: '免費',
            action: freeEquipped(category)
                ? Text('使用中', style: text.bodySmall)
                : PixelButton(
                    tone: PixelButtonTone.quiet,
                    onPressed: () => shop.unequip(category),
                    child: const Text('換上'),
                  ),
          ),
          for (final item in kShopItems.where((i) => i.category == category))
            ShopRow(
              preview: _preview(category, item.value, hero),
              name: item.name,
              detail: owned.contains(item.id)
                  ? '已擁有'
                  : '${item.rank.label} 級以上・${item.price} 金幣',
              action: owned.contains(item.id)
                  ? (isEquipped(item)
                        ? Text('使用中', style: text.bodySmall)
                        : PixelButton(
                            tone: PixelButtonTone.quiet,
                            onPressed: () => shop.equip(item),
                            child: const Text('換上'),
                          ))
                  : PixelButton(
                      onPressed:
                          hero == null || hero.guildRank.index < item.rank.index
                          ? null
                          : () => _buy(item),
                      child: Text(
                        hero == null || hero.guildRank.index < item.rank.index
                            ? '未解鎖'
                            : '購買',
                      ),
                    ),
            ),
        ],
      ],
    );
  }

  Widget _preview(ShopCategory category, String? value, Adventurer? hero) =>
      switch (category) {
        ShopCategory.portrait => PixelSpriteView(
          PixelPortraits.forAdventurer(value, hero?.heroClass),
        ),
        ShopCategory.frame =>
          value == null
              ? Text(
                  '稱號',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: PixelPalette.goldLight),
                )
              : TitleFrame(title: '稱號', frame: value),
        ShopCategory.wood => _WoodSwatch(BoardWood.parse(value)),
      };
}

class ShopRow extends StatelessWidget {
  const ShopRow({
    super.key,
    required this.preview,
    required this.name,
    required this.detail,
    required this.action,
  });

  final Widget preview;
  final String name;
  final String detail;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: PixelFrame(
        style: PixelFrameStyle.panel,
        child: Row(
          children: [
            SizedBox(width: 72, child: Center(child: preview)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: text.bodyMedium),
                  Text(detail, style: text.bodySmall),
                ],
              ),
            ),
            action,
          ],
        ),
      ),
    );
  }
}

/// A small piece of board in [wood].
class _WoodSwatch extends StatelessWidget {
  const _WoodSwatch(this.wood);
  final BoardWood wood;

  @override
  Widget build(BuildContext context) {
    final px = context.artPixel;
    return SizedBox(
      width: 40 * px,
      height: 24 * px,
      child: CustomPaint(painter: _SwatchPainter(wood, px)),
    );
  }
}

class _SwatchPainter extends CustomPainter {
  _SwatchPainter(this.wood, this.px);
  final BoardWood wood;
  final double px;

  @override
  void paint(Canvas canvas, Size size) => paintTexture(
    canvas,
    woodBoardTexture(40, 24, wood: wood),
    Offset.zero,
    px,
  );

  @override
  bool shouldRepaint(_SwatchPainter old) => old.wood != wood || old.px != px;
}
