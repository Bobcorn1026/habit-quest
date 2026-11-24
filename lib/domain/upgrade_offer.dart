import 'package:flutter/foundation.dart';

enum OfferKind {
  /// Legacy: the removed too-easy detector. Kept so old rows still load;
  /// treated like [surpass].
  stale,

  /// Consistently beating the target.
  surpass,

  /// A seal held long enough to tighten or retire.
  sealMastery,
}

enum OfferStatus { open, accepted, declined }

/// An NPC's invitation to take a quest to its next tier.
@immutable
class UpgradeOffer {
  const UpgradeOffer({
    required this.id,
    required this.questId,
    required this.kind,
    this.proposedTarget,
    required this.proposedTitle,
    this.proposedSubtitle = '',
    this.npcLine = '',
    this.status = OfferStatus.open,
    this.chapterId,
    required this.createdAt,
  });

  final int id;
  final int questId;
  final OfferKind kind;
  final double? proposedTarget;
  final String proposedTitle;
  final String proposedSubtitle;

  /// What the NPC says when offering, e.g. 「這卷軸對你來說太薄了吧？」
  final String npcLine;
  final OfferStatus status;
  final int? chapterId;
  final DateTime createdAt;
}
