/// Difficulty rank, F (trivial) to SSS (legendary). Used both for quests
/// and for the adventurer's guild rank.
enum QuestRank {
  f,
  e,
  d,
  c,
  b,
  a,
  s,
  ss,
  sss;

  String get label => name.toUpperCase();

  QuestRank get next =>
      index + 1 < QuestRank.values.length ? QuestRank.values[index + 1] : this;

  bool get isTop => this == QuestRank.values.last;

  static QuestRank parse(String raw) {
    final key = raw.trim().toLowerCase();
    return QuestRank.values.firstWhere(
      (r) => r.name == key,
      orElse: () => QuestRank.d,
    );
  }
}
