import 'package:drift/drift.dart';

import '../core/logical_day.dart';
import '../domain/bank.dart';
import '../domain/casino.dart';
import '../domain/chapter.dart';
import '../domain/check_in.dart';
import '../domain/habit.dart';
import '../domain/quest_rank.dart';
import '../domain/stat.dart';
import '../domain/upgrade_offer.dart';

/// Stores [LogicalDay] as `yyyy-MM-dd`, which also sorts correctly.
class LogicalDayConverter extends TypeConverter<LogicalDay, String> {
  const LogicalDayConverter();

  @override
  LogicalDay fromSql(String fromDb) => LogicalDay.parse(fromDb);

  @override
  String toSql(LogicalDay value) => value.toKey();
}

@DataClassName('AdventurerRow')
class Adventurers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get identity => text().nullable()();
  TextColumn get heroClass => text().nullable()();
  TextColumn get title => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  // Added in schema 2.
  /// Comma-separated `Stat` names; null until the class is appraised.
  TextColumn get classStats => text().nullable()();
  TextColumn get classSince =>
      text().map(const LogicalDayConverter()).nullable()();
  TextColumn get classFlavor => text().nullable()();
  TextColumn get portraitId => text().nullable()();
  TextColumn get guildRank =>
      textEnum<QuestRank>().withDefault(const Constant('f'))();
  TextColumn get rankSince =>
      text().map(const LogicalDayConverter()).nullable()();
  TextColumn get trialStart =>
      text().map(const LogicalDayConverter()).nullable()();
}

@DataClassName('HabitRow')
class Habits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get kind => textEnum<HabitKind>()();
  TextColumn get name => text()();
  TextColumn get unit => text().nullable()();
  RealColumn get target => real().nullable()();
  IntColumn get timesPerWeek => integer().withDefault(const Constant(7))();
  TextColumn get intention => text().nullable()();
  TextColumn get firstDay => text().map(const LogicalDayConverter())();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get archivedAt => dateTime().nullable()();

  // Added in schema 2.
  TextColumn get cursedOn =>
      text().map(const LogicalDayConverter()).nullable()();

  // Added in schema 5: habit stacking, "do this after ___". Either another
  // habit (no FK, so archiving the anchor never blocks) or a free-text cue.
  IntColumn get anchorHabitId => integer().nullable()();
  TextColumn get anchorText => text().nullable()();
}

@DataClassName('QuestRow')
// Schema 4: the active quest per habit is looked up on every board change.
@TableIndex(name: 'quests_habit_active', columns: {#habitId, #activeUntil})
class Quests extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get habitId => integer().references(Habits, #id)();
  IntColumn get tier => integer().withDefault(const Constant(1))();
  TextColumn get rank => textEnum<QuestRank>()();
  TextColumn get title => text()();
  TextColumn get subtitle => text().withDefault(const Constant(''))();
  TextColumn get flavor => text().withDefault(const Constant(''))();
  TextColumn get spriteId => text().withDefault(const Constant('scroll'))();
  RealColumn get target => real().nullable()();
  TextColumn get activeFrom => text().map(const LogicalDayConverter())();
  TextColumn get activeUntil =>
      text().map(const LogicalDayConverter()).nullable()();

  // Added in schema 2; null on older quests (guessed from the habit name).
  TextColumn get attribute => textEnum<Stat>().nullable()();
}

@DataClassName('CheckInRow')
// Schema 4: day ranges (`between`) and per-quest XP sums scan these.
@TableIndex(name: 'check_ins_day', columns: {#day})
@TableIndex(name: 'check_ins_quest', columns: {#questId})
class CheckIns extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get habitId => integer().references(Habits, #id)();
  IntColumn get questId => integer().references(Quests, #id)();
  TextColumn get day => text().map(const LogicalDayConverter())();
  TextColumn get outcome => textEnum<CheckInOutcome>()();
  RealColumn get amount => real().nullable()();
  TextColumn get note => text().nullable()();
  IntColumn get xp => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  // Added in schema 3.
  IntColumn get gold => integer().withDefault(const Constant(0))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {habitId, day},
  ];
}

/// XP that doesn't come from a single check-in (chapter bonuses, fixes).
@DataClassName('XpEventRow')
class XpEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get amount => integer()();
  TextColumn get source => text()();
  IntColumn get refId => integer().nullable()();
  DateTimeColumn get at => dateTime()();
}

/// Gold that doesn't come from a single check-in: perfect days, side
/// quests. Added in schema 3.
@DataClassName('GoldEventRow')
class GoldEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get amount => integer()();
  TextColumn get source => text()();

  /// e.g. the perfect day as `yyyy-MM-dd`, or a side quest id.
  TextColumn get ref => text().nullable()();
  DateTimeColumn get at => dateTime()();
}

/// Things bought in the guild shop. Added in schema 3.
@DataClassName('PurchaseRow')
class Purchases extends Table {
  TextColumn get itemId => text()();
  IntColumn get price => integer()();
  DateTimeColumn get at => dateTime()();

  @override
  Set<Column> get primaryKey => {itemId};
}

/// The price level of a week (`PriceRules`), fixed when the week starts so a
/// promotion only moves prices from the next week on. Added in schema 6.
@DataClassName('PriceWeekRow')
class PriceWeeks extends Table {
  TextColumn get weekStart => text().map(const LogicalDayConverter())();

  /// The guild rank the level was taken from.
  TextColumn get rank => textEnum<QuestRank>()();
  IntColumn get percent => integer()();

  @override
  Set<Column> get primaryKey => {weekStart};
}

/// A week at the training ground: the terms it runs on (`FocusTerms`), fixed
/// when it starts, and how it was settled. Added in schema 6.
@DataClassName('FocusWeekRow')
class FocusWeeks extends Table {
  TextColumn get weekStart => text().map(const LogicalDayConverter())();

  /// No debt is counted before this day: the week's first day, or the day
  /// focus was switched on.
  TextColumn get fromDay => text().map(const LogicalDayConverter())();
  IntColumn get dailyMinutes => integer()();
  IntColumn get capMinutes => integer()();
  IntColumn get earnCapMinutes => integer()();
  IntColumn get goldPerHour => integer()();

  /// Set once the week is closed, with what was still owed and the gold
  /// taken for it.
  DateTimeColumn get settledAt => dateTime().nullable()();
  IntColumn get unpaidSeconds => integer().nullable()();
  IntColumn get penalty => integer().nullable()();

  @override
  Set<Column> get primaryKey => {weekStart};
}

/// One sitting at the focus timer. Added in schema 6.
@DataClassName('FocusSessionRow')
@TableIndex(name: 'focus_sessions_day', columns: {#day})
class FocusSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get day => text().map(const LogicalDayConverter())();
  DateTimeColumn get startedAt => dateTime()();

  /// When the running session was last saved: where it ends if the app
  /// never comes back.
  DateTimeColumn get lastSeenAt => dateTime()();

  /// Set while the app is in the background.
  DateTimeColumn get hiddenAt => dateTime().nullable()();
  DateTimeColumn get endedAt => dateTime().nullable()();

  /// Time spent outside the app within the grace period; not focus.
  IntColumn get awaySeconds => integer().withDefault(const Constant(0))();

  /// Focused seconds so far; final once [endedAt] is set.
  IntColumn get seconds => integer().withDefault(const Constant(0))();
  TextColumn get endReason => text().nullable()();
}

/// An account of the bank: an envelope the player sees, or one of the hidden
/// system accounts (the vault, the casino's pool). Added in schema 7.
@DataClassName('BankAccountRow')
class BankAccounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();

  /// Null for a plain envelope.
  TextColumn get role => textEnum<AccountRole>().nullable()();

  /// A `PixelIcons` id.
  TextColumn get icon => text()();

  /// Share of the casino's prizes.
  IntColumn get weight => integer().withDefault(const Constant(0))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get archivedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

/// Money moving between accounts, or in or out of the bank (a null side is
/// the world outside). A balance is what came in minus what went out, over
/// the rows not voided. Added in schema 7.
@DataClassName('BankTxnRow')
@TableIndex(name: 'bank_txns_day', columns: {#day})
@TableIndex(name: 'bank_txns_from', columns: {#fromId})
@TableIndex(name: 'bank_txns_to', columns: {#toId})
class BankTxns extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Stable id outside this database (the Notion row's "App ID").
  TextColumn get uid => text().unique()();
  TextColumn get kind => textEnum<TxnKind>()();
  IntColumn get fromId => integer().nullable().references(BankAccounts, #id)();
  IntColumn get toId => integer().nullable().references(BankAccounts, #id)();
  // ignore: recursive_getters, drift reads the column it constrains
  IntColumn get amount => integer().check(amount.isBiggerThanValue(0))();
  TextColumn get day => text().map(const LogicalDayConverter())();
  DateTimeColumn get at => dateTime()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get note => text().withDefault(const Constant(''))();

  /// Makes an automatic move happen once (`meal:<day>`, `refill:<month>`…).
  TextColumn get ref => text().nullable().unique()();

  /// Rows that go together (a transfer and its fee) and are voided
  /// together.
  TextColumn get groupId => text().nullable()();

  /// The `FixedCost` this pays, charged or out of what was set aside.
  TextColumn get fixedId => text().nullable()();
  DateTimeColumn get voidedAt => dateTime().nullable()();

  // For the Notion sync (M4); unused until then.
  TextColumn get category => text().nullable()();
  BoolColumn get inbox => boolean().withDefault(const Constant(false))();
  TextColumn get notionPageId => text().nullable().unique()();
  DateTimeColumn get notionEditedAt => dateTime().nullable()();
  TextColumn get syncState => text().nullable()();
}

/// A month of the bank: the numbers it opened with (`BankConfig`), its meal
/// money day by day, and when it was closed. Added in schema 7.
@DataClassName('BankMonthRow')
class BankMonths extends Table {
  /// `yyyy-MM`.
  TextColumn get month => text()();

  /// The 1st, or the day the bank opened.
  TextColumn get firstDay => text().map(const LogicalDayConverter())();
  TextColumn get configJson => text()();

  /// Meal money of each day from [firstDay] on.
  TextColumn get mealPlanJson => text()();

  /// What the vault sets aside this month, by fixed cost id.
  TextColumn get reservesJson => text().withDefault(const Constant('{}'))();
  IntColumn get refill => integer()();
  DateTimeColumn get openedAt => dateTime()();
  DateTimeColumn get closedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {month};
}

/// A week at the casino: what it took out of the pool and the price of a
/// draw, fixed when it opens, and how it was settled. Added in schema 8.
@DataClassName('CasinoWeekRow')
class CasinoWeeks extends Table {
  TextColumn get weekStart => text().map(const LogicalDayConverter())();

  /// The week's first day, or the day the casino opened.
  TextColumn get fromDay => text().map(const LogicalDayConverter())();

  /// What the pool had free before the week took its money.
  IntColumn get poolBefore => integer()();

  /// The week's prize money; 0 when the pool had nothing to give.
  IntColumn get released => integer()();

  /// Gold per draw.
  IntColumn get price => integer()();

  /// The gold of the week with everything done (G*) the price is set on.
  IntColumn get targetGold => integer()();

  /// The week's price level, in percent.
  IntColumn get priceLevel => integer()();

  /// The month's release plan and the numbers the price came from.
  TextColumn get termsJson => text().withDefault(const Constant('{}'))();
  DateTimeColumn get openedAt => dateTime()();

  /// Set once the week is closed, with what went to the invest envelope.
  DateTimeColumn get settledAt => dateTime().nullable()();
  IntColumn get swept => integer().nullable()();

  @override
  Set<Column> get primaryKey => {weekStart};
}

/// A ticket of a casino week's deck. Added in schema 8.
@DataClassName('CasinoTicketRow')
@TableIndex(name: 'casino_tickets_week', columns: {#weekStart})
class CasinoTickets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get weekStart => text().map(const LogicalDayConverter())();
  TextColumn get kind => textEnum<TicketKind>()();

  /// Null for a refund.
  TextColumn get tier => textEnum<PrizeTier>().nullable()();
  IntColumn get amount => integer().withDefault(const Constant(0))();

  /// The envelope a prize pays into; null for a refund.
  IntColumn get accountId => integer().nullable()();

  /// Set once drawn, with the game it was drawn in and the gold paid.
  DateTimeColumn get drawnAt => dateTime().nullable()();
  TextColumn get game => textEnum<CasinoGame>().nullable()();
  IntColumn get paid => integer().nullable()();
}

@DataClassName('ChapterRow')
class Chapters extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get number => integer()();
  TextColumn get periodStart => text().map(const LogicalDayConverter())();
  IntColumn get periodDays => integer()();
  TextColumn get status => textEnum<ChapterStatus>()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get body => text().withDefault(const Constant(''))();
  TextColumn get choicesJson => text().withDefault(const Constant('[]'))();
  IntColumn get chosenIndex => integer().nullable()();
  TextColumn get recap => text().withDefault(const Constant(''))();
  TextColumn get judgement => text().nullable()();
  RealColumn get score => real().nullable()();

  /// Snapshot of the period's stats sent to the AI, kept for re-sends.
  TextColumn get statsJson => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get writtenAt => dateTime().nullable()();
}

@DataClassName('UpgradeOfferRow')
class UpgradeOffers extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get questId => integer().references(Quests, #id)();
  TextColumn get kind => textEnum<OfferKind>()();
  RealColumn get proposedTarget => real().nullable()();
  TextColumn get proposedTitle => text()();
  TextColumn get proposedSubtitle => text().withDefault(const Constant(''))();
  TextColumn get npcLine => text().withDefault(const Constant(''))();
  TextColumn get status => textEnum<OfferStatus>()();
  IntColumn get chapterId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

/// Small JSON blobs: story config, AI config (never the API key), world
/// bible, onboarding flags.
@DataClassName('SettingRow')
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
