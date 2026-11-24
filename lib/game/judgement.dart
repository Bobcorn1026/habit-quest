import 'game_rules.dart';
import 'habit_stats.dart';

/// The TRPG-style verdict on a period. Even a setback never ends the game;
/// it only colors the chapter.
enum Judgement {
  triumph('大成功'),
  success('成功'),
  struggle('苦戰'),
  setback('敗退');

  const Judgement(this.label);
  final String label;
}

/// Mean completion over habits that were scheduled at all; 0 when none were.
double performanceScore(Iterable<HabitPeriodStats> stats) {
  final counted = stats.where((s) => s.scheduled > 0).toList();
  if (counted.isEmpty) return 0;
  return counted.map((s) => s.completion).reduce((a, b) => a + b) /
      counted.length;
}

Judgement judge(double score, JudgementRules rules) {
  if (score >= rules.triumph) return Judgement.triumph;
  if (score >= rules.success) return Judgement.success;
  if (score >= rules.struggle) return Judgement.struggle;
  return Judgement.setback;
}
