import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../domain/chapter.dart';
import '../domain/side_quest.dart';
import '../domain/upgrade_offer.dart';
import '../game/checks.dart';
import '../game/judgement.dart';
import '../game/period.dart';
import 'database.dart';

/// The AI-written parts of a chapter.
@immutable
class ChapterContent {
  const ChapterContent({
    required this.title,
    required this.body,
    this.choices = const [],
    this.recap = '',
  });

  final String title;
  final String body;
  final List<StoryChoice> choices;
  final String recap;
}

class StoryRepository {
  StoryRepository(this._db);
  final AppDatabase _db;

  Stream<List<Chapter>> watchAll() =>
      (_db.select(_db.chapters)..orderBy([(t) => OrderingTerm.desc(t.number)]))
          .watch()
          .map((rows) => rows.map(_map).toList());

  Future<List<Chapter>> all() =>
      (_db.select(_db.chapters)..orderBy([(t) => OrderingTerm.asc(t.number)]))
          .get()
          .then((rows) => rows.map(_map).toList());

  Future<Chapter?> latest() =>
      (_db.select(_db.chapters)
            ..orderBy([(t) => OrderingTerm.desc(t.number)])
            ..limit(1))
          .getSingleOrNull()
          .then((r) => r == null ? null : _map(r));

  Future<Chapter> byId(int id) => (_db.select(
    _db.chapters,
  )..where((t) => t.id.equals(id))).getSingle().then(_map);

  /// Records that [period] ended and needs a chapter.
  Future<Chapter> createPending({
    required int number,
    required Period period,
    required Judgement? judgement,
    required double? score,
    required Map<String, Object?> stats,
    required DateTime now,
  }) async {
    final id = await _db
        .into(_db.chapters)
        .insert(
          ChaptersCompanion.insert(
            number: number,
            periodStart: period.start,
            periodDays: period.days,
            status: ChapterStatus.pending,
            judgement: Value(judgement?.name),
            score: Value(score),
            statsJson: Value(jsonEncode(stats)),
            createdAt: now,
          ),
        );
    return byId(id);
  }

  Future<Map<String, Object?>> statsOf(int chapterId) async {
    final row = await (_db.select(
      _db.chapters,
    )..where((t) => t.id.equals(chapterId))).getSingle();
    return (jsonDecode(row.statsJson) as Map).cast<String, Object?>();
  }

  /// Adds [extra] to the chapter's stored snapshot (e.g. its side quest).
  Future<void> mergeStats(int chapterId, Map<String, Object?> extra) async {
    final stats = {...await statsOf(chapterId), ...extra};
    await (_db.update(_db.chapters)..where((t) => t.id.equals(chapterId)))
        .write(ChaptersCompanion(statsJson: Value(jsonEncode(stats))));
  }

  Future<void> write(int id, ChapterContent c, {required DateTime now}) =>
      (_db.update(_db.chapters)..where((t) => t.id.equals(id))).write(
        ChaptersCompanion(
          status: const Value(ChapterStatus.written),
          title: Value(c.title),
          body: Value(c.body),
          choicesJson: Value(
            jsonEncode([for (final ch in c.choices) ch.toJson()]),
          ),
          recap: Value(c.recap),
          writtenAt: Value(now),
        ),
      );

  Future<void> choose(int id, int index) =>
      (_db.update(_db.chapters)..where((t) => t.id.equals(id))).write(
        ChaptersCompanion(chosenIndex: Value(index)),
      );

  Future<int> addOffer({
    required int questId,
    required OfferKind kind,
    double? proposedTarget,
    required String proposedTitle,
    String proposedSubtitle = '',
    String npcLine = '',
    int? chapterId,
    required DateTime now,
  }) => _db
      .into(_db.upgradeOffers)
      .insert(
        UpgradeOffersCompanion.insert(
          questId: questId,
          kind: kind,
          proposedTarget: Value(proposedTarget),
          proposedTitle: proposedTitle,
          proposedSubtitle: Value(proposedSubtitle),
          npcLine: Value(npcLine),
          status: OfferStatus.open,
          chapterId: Value(chapterId),
          createdAt: now,
        ),
      );

  Stream<List<UpgradeOffer>> watchOpenOffers() =>
      (_db.select(_db.upgradeOffers)
            ..where((t) => t.status.equalsValue(OfferStatus.open))
            ..orderBy([(t) => OrderingTerm.asc(t.id)]))
          .watch()
          .map((rows) => rows.map(_mapOffer).toList());

  Future<List<UpgradeOffer>> openOffers() => watchOpenOffers().first;

  /// Offers created at or after [since], whatever their status.
  Future<List<UpgradeOffer>> offersSince(DateTime since) =>
      (_db.select(_db.upgradeOffers)
            ..where((t) => t.createdAt.isBiggerOrEqualValue(since)))
          .get()
          .then((rows) => rows.map(_mapOffer).toList());

  Future<UpgradeOffer> offer(int id) => (_db.select(
    _db.upgradeOffers,
  )..where((t) => t.id.equals(id))).getSingle().then(_mapOffer);

  /// Replaces an offer's template lines with the chapter's AI-written ones.
  Future<void> updateOfferText(
    int id, {
    required String title,
    required String subtitle,
    required String npcLine,
    int? chapterId,
  }) => (_db.update(_db.upgradeOffers)..where((t) => t.id.equals(id))).write(
    UpgradeOffersCompanion(
      proposedTitle: Value(title),
      proposedSubtitle: Value(subtitle),
      npcLine: Value(npcLine),
      chapterId: Value(chapterId),
    ),
  );

  Future<void> resolveOffer(int id, OfferStatus status) =>
      (_db.update(_db.upgradeOffers)..where((t) => t.id.equals(id))).write(
        UpgradeOffersCompanion(status: Value(status)),
      );

  static Chapter _map(ChapterRow r) => Chapter(
    id: r.id,
    number: r.number,
    period: Period(r.periodStart, r.periodDays),
    status: r.status,
    title: r.title,
    body: r.body,
    choices: [
      for (final c in jsonDecode(r.choicesJson) as List)
        StoryChoice.fromJson((c as Map).cast<String, Object?>()),
    ],
    chosenIndex: r.chosenIndex,
    recap: r.recap,
    judgement: Judgement.values.where((j) => j.name == r.judgement).firstOrNull,
    score: r.score,
    checks: _checks(r.statsJson),
    sideQuest: SideQuest.fromJson(
      (jsonDecode(r.statsJson) as Map)['sideQuest'],
    ),
    createdAt: r.createdAt,
  );

  static List<StoryCheck> _checks(String statsJson) {
    final raw = (jsonDecode(statsJson) as Map)['checks'];
    return [
      for (final c in raw is List ? raw : const [])
        if (c is Map) StoryCheck.fromJson(c.cast<String, Object?>()),
    ];
  }

  static UpgradeOffer _mapOffer(UpgradeOfferRow r) => UpgradeOffer(
    id: r.id,
    questId: r.questId,
    kind: r.kind,
    proposedTarget: r.proposedTarget,
    proposedTitle: r.proposedTitle,
    proposedSubtitle: r.proposedSubtitle,
    npcLine: r.npcLine,
    status: r.status,
    chapterId: r.chapterId,
    createdAt: r.createdAt,
  );
}
