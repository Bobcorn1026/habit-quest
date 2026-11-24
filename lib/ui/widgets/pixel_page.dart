import 'package:flutter/material.dart';

import '../pixel/pixel.dart';

/// A full-screen page with the night backdrop, a back button and a title.
class PixelPage extends StatelessWidget {
  const PixelPage({
    super.key,
    required this.title,
    required this.children,
    this.showBack = true,
    this.bottom,
  });

  final String title;
  final List<Widget> children;
  final bool showBack;

  /// Pinned below the scrolling content (e.g. a primary button).
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: PixelBackdrop(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 16, 4),
                    child: Row(
                      children: [
                        if (showBack && Navigator.canPop(context)) ...[
                          PixelButton(
                            tone: PixelButtonTone.quiet,
                            onPressed: () => Navigator.maybePop(context),
                            child: const Text('←'),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: Text(
                            title,
                            style: text.titleLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      children: children,
                    ),
                  ),
                  if (bottom != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: bottom,
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

/// One selectable row in a vertical list of options.
class PixelOption extends StatelessWidget {
  const PixelOption({
    super.key,
    required this.selected,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.enabled = true,
  });

  final bool selected;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Semantics(
        selected: selected,
        button: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? onTap : null,
          child: Opacity(
            opacity: enabled ? 1 : 0.5,
            child: PixelFrame(
              style: selected ? PixelFrameStyle.ornate : PixelFrameStyle.panel,
              child: Row(
                children: [
                  PixelSpriteView(selected ? PixelIcons.star : PixelIcons.d20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: text.bodyMedium),
                        if (subtitle != null)
                          Text(subtitle!, style: text.bodySmall),
                      ],
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

/// 「－ 每週 4 次 ＋」: picks a whole number from [min] to [max] one step at a
/// time. Each button dims at its end of the range.
class PixelStepper extends StatelessWidget {
  const PixelStepper({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.label,
    required this.onChanged,
  });

  final int value;
  final int min;
  final int max;
  final String Function(int) label;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PixelButton(
          tone: PixelButtonTone.quiet,
          onPressed: value > min ? () => onChanged(value - 1) : null,
          child: const Text('－'),
        ),
        Expanded(
          child: Text(
            label(value),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        PixelButton(
          tone: PixelButtonTone.quiet,
          onPressed: value < max ? () => onChanged(value + 1) : null,
          child: const Text('＋'),
        ),
      ],
    );
  }
}

/// A row of small buttons where exactly one is active.
class PixelSegments<T> extends StatelessWidget {
  const PixelSegments({
    super.key,
    required this.values,
    required this.selected,
    required this.label,
    required this.onChanged,
  });

  final List<T> values;
  final T selected;
  final String Function(T) label;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final v in values)
          PixelButton(
            tone: v == selected ? PixelButtonTone.gold : PixelButtonTone.quiet,
            onPressed: () => onChanged(v),
            child: Text(label(v)),
          ),
      ],
    );
  }
}
