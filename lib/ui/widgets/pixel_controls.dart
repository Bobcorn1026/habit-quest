import 'package:flutter/material.dart';

import '../pixel/pixel.dart';

/// A text input inside a dark pixel panel.
class PixelTextField extends StatelessWidget {
  const PixelTextField({
    super.key,
    this.controller,
    this.hint,
    this.maxLines = 1,
    this.minLines,
    this.keyboardType,
    this.autofocus = false,
    this.onChanged,
    this.textInputAction,
    this.obscure = false,
    this.onSubmitted,
  });

  final bool obscure;
  final ValueChanged<String>? onSubmitted;
  final TextEditingController? controller;
  final String? hint;
  final int? maxLines;
  final int? minLines;
  final TextInputType? keyboardType;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return PixelFrame(
      style: PixelFrameStyle.panel,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        maxLines: maxLines,
        minLines: minLines,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        obscureText: obscure,
        autocorrect: !obscure,
        enableSuggestions: !obscure,
        style: text.bodyMedium,
        cursorColor: PixelPalette.gold,
        cursorWidth: context.artPixel,
        decoration: InputDecoration.collapsed(
          hintText: hint,
          hintStyle: text.bodyMedium?.copyWith(color: PixelPalette.panelLight),
        ),
      ),
    );
  }
}

/// A modal sheet framed in gold, sliding up from the bottom. It stays below
/// the status bar, and when the keyboard leaves too little room the content
/// scrolls inside the frame.
Future<T?> showPixelSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0xB30D0A12),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: PixelFrame(
                style: PixelFrameStyle.ornate,
                child: SingleChildScrollView(child: builder(ctx)),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// A centered gold-framed dialog.
Future<T?> showPixelDialog<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool dismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: dismissible,
    barrierColor: const Color(0xB30D0A12),
    builder: (ctx) => Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Material(
            type: MaterialType.transparency,
            child: PixelFrame(
              style: PixelFrameStyle.ornate,
              child: builder(ctx),
            ),
          ),
        ),
      ),
    ),
  );
}

/// A short floating notice, e.g. 「+22 EXP」.
void showPixelToast(
  BuildContext context,
  String message, {
  PixelSprite icon = PixelIcons.star,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(milliseconds: 1800),
      padding: EdgeInsets.zero,
      content: PixelFrame(
        style: PixelFrameStyle.panel,
        child: Row(
          children: [
            PixelSpriteView(icon),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Section heading with a small sprite.
class PixelHeading extends StatelessWidget {
  const PixelHeading(
    this.title, {
    super.key,
    this.icon = PixelIcons.star,
    this.trailing,
  });

  final String title;
  final PixelSprite icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Row(
        children: [
          PixelSpriteView(icon),
          const SizedBox(width: 8),
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// The bottom navigation strip.
class PixelTabBar extends StatelessWidget {
  const PixelTabBar({
    super.key,
    required this.items,
    required this.index,
    required this.onSelect,
  });

  final List<(PixelSprite, String)> items;
  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return CustomPaint(
      painter: FramePainter(
        const FrameSpec(
          rings: [
            FrameRing(PixelPalette.outline),
            FrameRing(PixelPalette.wood5, PixelPalette.wood1),
          ],
          fill: PixelPalette.wood2,
          foreground: PixelPalette.parchmentLight,
          texture: FrameTexture.beam,
          roundCorners: false,
        ),
        context.artPixel,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          // Keep the tabs under the content column on wide screens (iPad).
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Row(
                children: [
                  for (final (i, (icon, label)) in items.indexed)
                    Expanded(
                      child: Semantics(
                        button: true,
                        selected: i == index,
                        label: label,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onSelect(i),
                          child: Opacity(
                            opacity: i == index ? 1 : 0.55,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                PixelSpriteView(icon),
                                const SizedBox(height: 2),
                                Text(
                                  label,
                                  style: text.labelMedium?.copyWith(
                                    color: i == index
                                        ? PixelPalette.goldLight
                                        : PixelPalette.parchmentLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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

/// 「11月4日（三）」
String formatDayLabel(int month, int day, int weekday) {
  const names = ['一', '二', '三', '四', '五', '六', '日'];
  return '$month月$day日（${names[weekday - 1]}）';
}

/// Drops a trailing `.0` from whole numbers.
String formatAmount(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
