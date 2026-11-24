import 'package:flutter/foundation.dart';

import '../core/logical_day.dart';
import '../domain/chapter.dart';

/// The blessing from the latest chosen chapter choice, while its period
/// lasts.
@immutable
class ActiveBlessing {
  const ActiveBlessing(this.blessing, this.until);

  final Blessing blessing;

  /// Last day it applies.
  final LogicalDay until;
}

/// A choice in a chapter blesses the period after that chapter's: from the
/// chapter's end for [periodDays] days.
ActiveBlessing? activeBlessing({
  required List<Chapter> chapters,
  required LogicalDay today,
  required int periodDays,
}) {
  final chosen = chapters.where((c) => c.chosen?.blessing != null).toList()
    ..sort((a, b) => b.number.compareTo(a.number));
  for (final c in chosen) {
    final from = c.period.endExclusive;
    final until = from.addDays(periodDays - 1);
    if (!today.isBefore(from) && !today.isAfter(until)) {
      return ActiveBlessing(c.chosen!.blessing!, until);
    }
    if (today.isAfter(until)) return null;
  }
  return null;
}
