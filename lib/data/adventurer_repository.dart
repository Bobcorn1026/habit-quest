import 'package:drift/drift.dart';

import '../core/logical_day.dart';
import '../domain/adventurer.dart';
import '../domain/hero_class.dart';
import '../domain/quest_rank.dart';
import '../domain/stat.dart';
import 'database.dart';

class AdventurerRepository {
  AdventurerRepository(this._db);
  final AppDatabase _db;

  Stream<Adventurer?> watch() =>
      (_db.select(_db.adventurers)
            ..orderBy([(t) => OrderingTerm.asc(t.id)])
            ..limit(1))
          .watchSingleOrNull()
          .map((r) => r == null ? null : _map(r));

  Future<Adventurer?> get() =>
      (_db.select(_db.adventurers)
            ..orderBy([(t) => OrderingTerm.asc(t.id)])
            ..limit(1))
          .getSingleOrNull()
          .then((r) => r == null ? null : _map(r));

  Future<int> create({
    required String name,
    String? identity,
    required DateTime now,
  }) => _db
      .into(_db.adventurers)
      .insert(
        AdventurersCompanion.insert(
          name: name,
          identity: Value(identity),
          createdAt: now,
        ),
      );

  Future<void> updateClassAndTitle(
    int id, {
    String? heroClass,
    String? title,
  }) => (_db.update(_db.adventurers)..where((t) => t.id.equals(id))).write(
    AdventurersCompanion(
      heroClass: heroClass == null ? const Value.absent() : Value(heroClass),
      title: title == null ? const Value.absent() : Value(title),
    ),
  );

  Future<void> _write(int id, AdventurersCompanion c) =>
      (_db.update(_db.adventurers)..where((t) => t.id.equals(id))).write(c);

  /// Takes [heroClass]; mastery starts over from its `since` day.
  Future<void> setClass(int id, HeroClass heroClass, {String? portraitId}) =>
      _write(
        id,
        AdventurersCompanion(
          heroClass: Value(heroClass.name),
          classStats: Value(heroClass.stats.map((s) => s.name).join(',')),
          classSince: Value(heroClass.since),
          classFlavor: Value(heroClass.flavor),
          portraitId: portraitId == null
              ? const Value.absent()
              : Value(portraitId),
        ),
      );

  Future<void> setPortrait(int id, String? portraitId) =>
      _write(id, AdventurersCompanion(portraitId: Value(portraitId)));

  Future<void> startTrial(int id, LogicalDay day) =>
      _write(id, AdventurersCompanion(trialStart: Value(day)));

  Future<void> promote(int id, QuestRank rank, LogicalDay day) => _write(
    id,
    AdventurersCompanion(
      guildRank: Value(rank),
      rankSince: Value(day),
      trialStart: const Value(null),
    ),
  );

  static Adventurer _map(AdventurerRow r) {
    final stats = Stat.parseList(r.classStats);
    return Adventurer(
      id: r.id,
      name: r.name,
      identity: r.identity,
      heroClass: r.heroClass,
      classInfo: stats.isEmpty || r.classSince == null
          ? null
          : HeroClass(
              name: r.heroClass ?? '',
              stats: stats,
              since: r.classSince!,
              flavor: r.classFlavor ?? '',
            ),
      title: r.title,
      portraitId: r.portraitId,
      guildRank: r.guildRank,
      rankSince: r.rankSince,
      trialStart: r.trialStart,
      createdAt: r.createdAt,
    );
  }
}
