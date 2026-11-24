import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../core/logical_day.dart';
import '../domain/habit.dart';
import '../domain/quest.dart';
import '../domain/quest_rank.dart';
import '../domain/stat.dart';
import '../game/stacking.dart';
import 'database.dart';

/// What the user typed when adding a habit.
@immutable
class HabitDraft {
  const HabitDraft({
    required this.kind,
    required this.name,
    this.unit,
    this.target,
    this.timesPerWeek = 7,
    this.intention,
    this.anchorHabitId,
    this.anchorText,
  });

  final HabitKind kind;
  final String name;
  final String? unit;
  final double? target;
  final int timesPerWeek;
  final String? intention;

  /// Habit stacking: at most one of these is set.
  final int? anchorHabitId;
  final String? anchorText;
}

/// The RPG wrapping for a habit, from the AI or a template.
@immutable
class QuestDraft {
  const QuestDraft({
    required this.rank,
    required this.title,
    this.subtitle = '',
    this.flavor = '',
    this.spriteId = 'scroll',
    this.target,
    this.attribute,
  });

  final QuestRank rank;
  final String title;
  final String subtitle;
  final String flavor;
  final String spriteId;
  final double? target;
  final Stat? attribute;
}

typedef QuestInfo = ({Stat attribute, QuestRank rank});

/// A habit with its current quest tier.
@immutable
class ActiveQuest {
  const ActiveQuest(this.habit, this.quest);
  final Habit habit;
  final Quest quest;

  /// The stat this quest trains, guessed for quests older than attributes.
  Stat get attribute =>
      quest.attribute ?? guessAttribute(habit.name, habit.kind);
}

class HabitRepository {
  HabitRepository(this._db);
  final AppDatabase _db;

  /// Adds a habit and its first quest tier atomically.
  Future<ActiveQuest> create(
    HabitDraft habit,
    QuestDraft quest, {
    required DateTime now,
    required LogicalDay today,
  }) {
    return _db.transaction(() async {
      final habitId = await _db
          .into(_db.habits)
          .insert(
            HabitsCompanion.insert(
              kind: habit.kind,
              name: habit.name,
              unit: Value(habit.unit),
              target: Value(habit.target),
              timesPerWeek: Value(
                habit.kind == HabitKind.quit ? 7 : habit.timesPerWeek,
              ),
              intention: Value(habit.intention),
              anchorHabitId: Value(habit.anchorHabitId),
              anchorText: Value(habit.anchorText),
              firstDay: today,
              createdAt: now,
            ),
          );
      final questId = await _insertQuest(habitId, 1, quest, today);
      return ActiveQuest(
        _mapHabit(await _habitRow(habitId)),
        _mapQuest(await _questRow(questId)),
      );
    });
  }

  /// Ends the current tier yesterday and starts [next] today.
  Future<Quest> upgrade(
    int habitId,
    QuestDraft next, {
    required LogicalDay today,
  }) {
    return _db.transaction(() async {
      final current = await _currentQuestRow(habitId);
      await (_db.update(_db.quests)..where((t) => t.id.equals(current.id)))
          .write(QuestsCompanion(activeUntil: Value(today.addDays(-1))));
      if (next.target != null) {
        await (_db.update(_db.habits)..where((t) => t.id.equals(habitId)))
            .write(HabitsCompanion(target: Value(next.target)));
      }
      final id = await _insertQuest(habitId, current.tier + 1, next, today);
      return _mapQuest(await _questRow(id));
    });
  }

  /// Rewrites the RPG text of the current tier (e.g. after the AI forged a
  /// better name than the template).
  Future<void> reskin(int questId, QuestDraft draft) =>
      (_db.update(_db.quests)..where((t) => t.id.equals(questId))).write(
        QuestsCompanion(
          rank: Value(draft.rank),
          title: Value(draft.title),
          subtitle: Value(draft.subtitle),
          flavor: Value(draft.flavor),
          spriteId: Value(draft.spriteId),
          attribute: draft.attribute == null
              ? const Value.absent()
              : Value(draft.attribute),
        ),
      );

  /// Changes what the habit asks for. The current tier's target follows;
  /// [cursedOn] marks the day the edit was paid for. The draft's anchor is
  /// saved too (unless it would make a cycle: then the old one stays).
  Future<void> edit(
    int habitId,
    HabitDraft draft, {
    required LogicalDay cursedOn,
  }) => _db.transaction(() async {
    final anchor = await _checkedAnchor(
      habitId,
      draft.anchorHabitId,
      draft.anchorText,
    );
    await (_db.update(_db.habits)..where((t) => t.id.equals(habitId))).write(
      HabitsCompanion(
        name: Value(draft.name),
        unit: Value(draft.unit),
        target: Value(draft.target),
        timesPerWeek: Value(draft.timesPerWeek),
        intention: Value(draft.intention),
        cursedOn: Value(cursedOn),
        anchorHabitId: Value(anchor?.habitId),
        anchorText: Value(anchor?.text),
      ),
    );
    final current = await _currentQuestRow(habitId);
    await (_db.update(_db.quests)..where((t) => t.id.equals(current.id))).write(
      QuestsCompanion(target: Value(draft.target)),
    );
  });

  /// Sets, changes or (with both null) clears the habit's "do this after".
  /// This is not an edit of the habit: no curse. Returns false, changing
  /// nothing, when [anchorHabitId] is the habit itself or would make a cycle.
  Future<bool> setAnchor(
    int habitId, {
    int? anchorHabitId,
    String? anchorText,
  }) => _db.transaction(() async {
    final anchor = await _checkedAnchor(habitId, anchorHabitId, anchorText);
    if (anchorHabitId != null && anchor?.habitId != anchorHabitId) {
      return false;
    }
    await (_db.update(_db.habits)..where((t) => t.id.equals(habitId))).write(
      HabitsCompanion(
        anchorHabitId: Value(anchor?.habitId),
        anchorText: Value(anchor?.text),
      ),
    );
    return true;
  });

  /// Normalises an anchor: a habit wins over text, blank text is none. A
  /// habit anchor that would cycle falls back to the saved anchor.
  Future<({int? habitId, String? text})?> _checkedAnchor(
    int habitId,
    int? anchorHabitId,
    String? anchorText,
  ) async {
    if (anchorHabitId != null) {
      final anchors = {
        for (final a in await active()) a.habit.id: a.habit.anchorHabitId,
      };
      if (!anchors.containsKey(anchorHabitId) ||
          anchorWouldCycle(habitId, anchorHabitId, anchors)) {
        final now = await habit(habitId);
        return now.anchorHabitId == null && now.anchorText == null
            ? null
            : (habitId: now.anchorHabitId, text: now.anchorText);
      }
      return (habitId: anchorHabitId, text: null);
    }
    final text = anchorText?.trim();
    if (text == null || text.isEmpty) return null;
    return (habitId: null, text: text);
  }

  Future<void> clearCurse(int habitId) =>
      (_db.update(_db.habits)..where((t) => t.id.equals(habitId))).write(
        const HabitsCompanion(cursedOn: Value(null)),
      );

  /// Every quest tier ever made (archived habits included): the stat it
  /// trains and its rank, for lifetime stats and guild points.
  Stream<Map<int, QuestInfo>> watchQuestIndex() {
    final q = _db.select(_db.quests).join([
      innerJoin(_db.habits, _db.habits.id.equalsExp(_db.quests.habitId)),
    ]);
    return q.watch().map((rows) {
      final out = <int, QuestInfo>{};
      for (final r in rows) {
        final aq = ActiveQuest(
          _mapHabit(r.readTable(_db.habits)),
          _mapQuest(r.readTable(_db.quests)),
        );
        out[aq.quest.id] = (attribute: aq.attribute, rank: aq.quest.rank);
      }
      return out;
    });
  }

  Future<Map<int, QuestInfo>> questIndex() => watchQuestIndex().first;

  Future<void> archive(int habitId, DateTime now) =>
      (_db.update(_db.habits)..where((t) => t.id.equals(habitId))).write(
        HabitsCompanion(archivedAt: Value(now)),
      );

  Stream<List<ActiveQuest>> watchActive() =>
      _activeQuery().watch().map(_mapJoined);
  Future<List<ActiveQuest>> active() => _activeQuery().get().then(_mapJoined);

  Future<Habit> habit(int id) => _habitRow(id).then(_mapHabit);
  Future<Quest> quest(int id) => _questRow(id).then(_mapQuest);

  /// Every tier of a habit, oldest first.
  Future<List<Quest>> tiers(int habitId) =>
      (_db.select(_db.quests)
            ..where((t) => t.habitId.equals(habitId))
            ..orderBy([(t) => OrderingTerm.asc(t.tier)]))
          .get()
          .then((rows) => rows.map(_mapQuest).toList());

  JoinedSelectStatement<HasResultSet, dynamic> _activeQuery() {
    return _db.select(_db.habits).join([
        innerJoin(
          _db.quests,
          _db.quests.habitId.equalsExp(_db.habits.id) &
              _db.quests.activeUntil.isNull(),
        ),
      ])
      ..where(_db.habits.archivedAt.isNull())
      ..orderBy([
        OrderingTerm.asc(_db.habits.kind),
        OrderingTerm.asc(_db.habits.id),
      ]);
  }

  List<ActiveQuest> _mapJoined(List<TypedResult> rows) => [
    for (final r in rows)
      ActiveQuest(
        _mapHabit(r.readTable(_db.habits)),
        _mapQuest(r.readTable(_db.quests)),
      ),
  ];

  Future<int> _insertQuest(
    int habitId,
    int tier,
    QuestDraft q,
    LogicalDay from,
  ) => _db
      .into(_db.quests)
      .insert(
        QuestsCompanion.insert(
          habitId: habitId,
          tier: Value(tier),
          rank: q.rank,
          title: q.title,
          subtitle: Value(q.subtitle),
          flavor: Value(q.flavor),
          spriteId: Value(q.spriteId),
          target: Value(q.target),
          attribute: Value(q.attribute),
          activeFrom: from,
        ),
      );

  Future<HabitRow> _habitRow(int id) =>
      (_db.select(_db.habits)..where((t) => t.id.equals(id))).getSingle();

  Future<QuestRow> _questRow(int id) =>
      (_db.select(_db.quests)..where((t) => t.id.equals(id))).getSingle();

  Future<QuestRow> _currentQuestRow(int habitId) =>
      (_db.select(_db.quests)
            ..where((t) => t.habitId.equals(habitId) & t.activeUntil.isNull()))
          .getSingle();

  static Habit _mapHabit(HabitRow r) => Habit(
    id: r.id,
    kind: r.kind,
    name: r.name,
    unit: r.unit,
    target: r.target,
    timesPerWeek: r.timesPerWeek,
    intention: r.intention,
    firstDay: r.firstDay,
    createdAt: r.createdAt,
    archivedAt: r.archivedAt,
    cursedOn: r.cursedOn,
    anchorHabitId: r.anchorHabitId,
    anchorText: r.anchorText,
  );

  static Quest _mapQuest(QuestRow r) => Quest(
    id: r.id,
    habitId: r.habitId,
    tier: r.tier,
    rank: r.rank,
    title: r.title,
    subtitle: r.subtitle,
    flavor: r.flavor,
    spriteId: r.spriteId,
    target: r.target,
    attribute: r.attribute,
    activeFrom: r.activeFrom,
    activeUntil: r.activeUntil,
  );
}
