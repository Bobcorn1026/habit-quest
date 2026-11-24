import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../ai/secret_store.dart';
import '../core/clock.dart';
import '../data/bank_repository.dart';
import '../data/database.dart';
import '../data/settings_repository.dart';
import '../domain/bank.dart';
import '../notion/ledger.dart';
import '../notion/notion_client.dart';
import 'ai_providers.dart';
import 'providers.dart';

/// The link to the Notion ledger, kept in settings.
@immutable
class NotionLink {
  const NotionLink({
    this.since,
    this.cursor,
    this.lastSync,
    this.error,
    this.ledger,
    this.budget,
  });

  factory NotionLink.fromJson(Object? raw) {
    if (raw is! Map) return const NotionLink();
    DateTime? time(Object? v) =>
        v is String ? DateTime.tryParse(v)?.toLocal() : null;
    return NotionLink(
      since: time(raw['since']),
      cursor: time(raw['cursor']),
      lastSync: time(raw['lastSync']),
      error: raw['error'] as String?,
      ledger: raw['ledger'] as String?,
      budget: raw['budget'] as String?,
    );
  }

  /// When the link was made, to the minute (Notion's times are): rows
  /// created before it stay where they are, since the vault's opening
  /// balance already holds them. Null when not linked.
  final DateTime? since;

  /// The newest `last_edited_time` read from the ledger.
  final DateTime? cursor;
  final DateTime? lastSync;

  /// Why the last sync failed; null when it worked.
  final String? error;

  /// The ledger's data source, found by its title when linking; null for a
  /// link made before the app searched for it (found on the next sync).
  final String? ledger;

  /// The budget data source the ledger relates to; null when there is none.
  final String? budget;

  bool get linked => since != null;

  Map<String, Object?> toJson() => {
    'since': ?since?.toUtc().toIso8601String(),
    'cursor': ?cursor?.toUtc().toIso8601String(),
    'lastSync': ?lastSync?.toIso8601String(),
    'error': ?error,
    'ledger': ?ledger,
    'budget': ?budget,
  };

  NotionLink copyWith({
    DateTime? cursor,
    DateTime? lastSync,
    String? ledger,
    String? budget,
  }) => NotionLink(
    since: since,
    cursor: cursor ?? this.cursor,
    lastSync: lastSync ?? this.lastSync,
    error: error,
    ledger: ledger ?? this.ledger,
    budget: budget ?? this.budget,
  );
}

/// Accounts by the names the ledger's 帳戶 uses.
class _Accounts {
  _Accounts(List<BankAccountRow> rows)
    : vault = rows.firstWhere((a) => a.role == AccountRole.central).id,
      _byName = {
        // Archived first, so an open account wins a shared name.
        for (final a in [
          ...rows.where((a) => a.archivedAt != null),
          ...rows.where((a) => a.archivedAt == null),
        ])
          if (a.role != AccountRole.central && a.role != AccountRole.pool)
            a.name: a.id,
      },
      _names = {for (final a in rows) a.id: a.name};

  final int vault;
  final Map<String, int> _byName;
  final Map<int, String> _names;

  int? idOf(String? name) => name == kVaultName ? vault : _byName[name];

  String nameOf(int? id) =>
      id == null || id == vault ? kVaultName : _names[id] ?? kVaultName;
}

/// Keeps the bank and the Notion ledger in step, both ways.
///
/// Rows of the ledger dated on or after the link day become the bank's
/// expenses and income; money spent or earned by hand in the app becomes
/// ledger rows. The bank's own moves (meal money, prizes, transfers,
/// month ends, fixed costs) stay out of Notion, and the ledger's
/// recurring rows and monthly income stay out of the bank, which counts
/// those itself.
class NotionSync {
  NotionSync({
    required this.db,
    required this.bank,
    required this.settings,
    required this.secrets,
    required this.httpClient,
    required this.clock,
    this.sleep,
  });

  final AppDatabase db;
  final BankRepository bank;
  final SettingsRepository settings;
  final SecretStore secrets;
  final http.Client httpClient;
  final Clock clock;
  final Future<void> Function(Duration)? sleep;

  /// How far back a row is checked for having been deleted in Notion.
  static const deleteWindow = 45;

  /// Edits can land in the same minute as the newest one already read.
  static const cursorOverlap = Duration(minutes: 5);

  Future<NotionLink> link() async =>
      NotionLink.fromJson(await settings.read(SettingKeys.notion));

  Future<void> _save(NotionLink link) =>
      settings.write(SettingKeys.notion, link.toJson());

  NotionClient _client(String token) =>
      NotionClient(httpClient: httpClient, token: token, sleep: sleep);

  Future<String?> _token() async {
    final token = (await secrets.read(SecretKeys.notion))?.trim();
    return token == null || token.isEmpty ? null : token;
  }

  /// Finds the ledger shared with the integration, and its budget table.
  Future<({String ledger, String? budget})> _find(NotionClient client) async {
    final ledger = await client.findDataSource(kLedgerTitle);
    if (ledger == null) {
      throw const NotionException(404, 'ledger_not_found', kLedgerTitle);
    }
    return (
      ledger: ledger,
      budget: budgetSourceOf(await client.dataSource(ledger)),
    );
  }

  /// Checks the saved token can find and read the ledger; the ledger's
  /// data sources when it can, the reason when it can't.
  Future<({String ledger, String? budget})?> _probe(
    void Function(NotionException) fail,
  ) async {
    final token = await _token();
    if (token == null) {
      fail(const NotionException(401, 'no_token', 'no token'));
      return null;
    }
    try {
      return await _find(_client(token));
    } on NotionException catch (e) {
      fail(e);
      return null;
    }
  }

  /// Linking before the bank is open would bring in rows that the
  /// opening balance will hold already.
  static const bankClosed = NotionException(-1, 'bank_closed', 'no bank');

  /// Links from now on and syncs; the reason when it can't.
  Future<NotionException?> start() async {
    if (await bank.byRole(AccountRole.central) == null) return bankClosed;
    NotionException? problem;
    final found = await _probe((e) => problem = e);
    if (found == null) return problem;
    final current = await link();
    final now = clock.now();
    await _save(
      current.linked
          ? current.copyWith(ledger: found.ledger, budget: found.budget)
          : NotionLink(
              since: DateTime(
                now.year,
                now.month,
                now.day,
                now.hour,
                now.minute,
              ),
              ledger: found.ledger,
              budget: found.budget,
            ),
    );
    await sync();
    return null;
  }

  /// Stops syncing. What was synced stays in the bank; a sync under way
  /// stops at its next step.
  Future<void> stop() => _save(const NotionLink());

  Completer<void>? _running;
  bool _again = false;

  /// Syncs; when a sync is under way, another follows it, and the future
  /// completes when the last one ends. Never throws: failures are kept in
  /// the link's `error`.
  Future<void> sync() {
    final running = _running;
    if (running != null) {
      _again = true;
      return running.future;
    }
    final done = _running = Completer<void>();
    unawaited(_loop(done));
    return done.future;
  }

  Future<void> _loop(Completer<void> done) async {
    try {
      do {
        _again = false;
        await _syncOnce();
      } while (_again);
    } catch (e, s) {
      debugPrint('Notion sync: $e\n$s');
    } finally {
      _running = null;
      done.complete();
    }
  }

  /// Whether the link made at [since] still stands (not stopped or remade
  /// while a sync was under way).
  Future<bool> _still(DateTime since) async {
    final now = (await link()).since;
    return now != null && now.isAtSameMomentAs(since);
  }

  Future<void> _saveIfStill(DateTime since, NotionLink next) async {
    if (await _still(since)) await _save(next);
  }

  Future<void> _syncOnce() async {
    var current = await link();
    final since = current.since;
    if (since == null) return;
    final token = await _token();
    if (token == null) {
      await _save(_with(current, error: '還沒設定 Notion 金鑰'));
      return;
    }
    final client = _client(token);
    try {
      if (current.ledger == null) {
        // Linked before the app searched for the ledger.
        final found = await _find(client);
        current = current.copyWith(ledger: found.ledger, budget: found.budget);
        await _saveIfStill(since, current);
      }
      current = await _pull(client, current, since);
      if (!await _still(since)) return;
      await _push(client, current, since);
      await _saveIfStill(
        since,
        NotionLink(
          since: since,
          cursor: current.cursor,
          lastSync: clock.now(),
          ledger: current.ledger,
          budget: current.budget,
        ),
      );
    } on NotionException catch (e) {
      debugPrint('Notion sync: $e');
      await _saveIfStill(since, _with(current, error: e.friendly));
    } on Object catch (e, s) {
      debugPrint('Notion sync: $e\n$s');
      final text = '$e';
      await _saveIfStill(
        since,
        _with(
          current,
          error: '同步出錯了：${text.length > 60 ? text.substring(0, 60) : text}',
        ),
      );
    }
  }

  NotionLink _with(NotionLink link, {String? error}) => NotionLink(
    since: link.since,
    cursor: link.cursor,
    lastSync: link.lastSync,
    error: error,
    ledger: link.ledger,
    budget: link.budget,
  );

  static Map<String, Object?> _createdFrom(DateTime time) => {
    'timestamp': 'created_time',
    'created_time': {'on_or_after': time.toUtc().toIso8601String()},
  };

  /// Reads what changed in the ledger and what was deleted from it, then
  /// writes it all to the bank in one go. Returns the link with the new
  /// cursor, saved already.
  Future<NotionLink> _pull(
    NotionClient client,
    NotionLink link,
    DateTime since,
  ) async {
    final cursor = link.cursor;
    final changed = [
      for (final page in await client.queryAll(
        link.ledger!,
        filter: cursor == null
            ? _createdFrom(since)
            : {
                'timestamp': 'last_edited_time',
                'last_edited_time': {
                  'on_or_after': cursor
                      .subtract(cursorOverlap)
                      .toUtc()
                      .toIso8601String(),
                },
              },
      ))
        LedgerRow.parse(page),
    ];

    // Pages in the trash never come back from a query, so the ones that
    // went missing lately are looked up one by one.
    final windowStart = clock.now().subtract(
      const Duration(days: deleteWindow),
    );
    final from = since.isAfter(windowStart) ? since : windowStart;
    final listed = {
      for (final page in await client.queryAll(
        link.ledger!,
        filter: _createdFrom(from),
        onlyProperties: const ['title'],
      ))
        '${page['id']}',
    };
    final seen = {for (final row in changed) row.pageId};
    final gone = <int>[];
    for (final local in await bank.linkedTxns(from: from)) {
      final pageId = local.notionPageId!;
      final voided = local.voidedAt != null;
      // Voided here and waiting to be trashed there: the push sees to it.
      if (seen.contains(pageId) ||
          (voided && local.syncState != SyncState.trashed)) {
        continue;
      }
      // Live and listed, or gone and not listed: nothing new. Otherwise
      // the page left (trash, deleted) or came back (restored).
      if (voided != listed.contains(pageId)) continue;
      final page = await client.page(pageId);
      final row = page == null ? null : LedgerRow.parse(page);
      if (row == null || row.trashed) {
        if (!voided) gone.add(local.id);
      } else {
        changed.add(row);
      }
    }

    var newest = cursor;
    for (final row in changed) {
      if (newest == null || row.editedAt.isAfter(newest)) newest = row.editedAt;
    }
    if (!await _still(since)) return link;
    await db.transaction(() async {
      final accounts = _Accounts(await bank.accounts());
      for (final row in changed) {
        await _apply(row, since, accounts);
      }
      for (final id in gone) {
        await bank.patchTxn(
          id,
          BankTxnsCompanion(
            voidedAt: Value(clock.now()),
            syncState: const Value(SyncState.trashed),
          ),
        );
      }
    });
    final next = NotionLink(
      since: since,
      cursor: newest,
      lastSync: link.lastSync,
      error: link.error,
      ledger: link.ledger,
      budget: link.budget,
    );
    await _saveIfStill(since, next);
    return next;
  }

  Future<void> _apply(LedgerRow row, DateTime since, _Accounts accounts) async {
    var local = await bank.txnByPage(row.pageId);
    final appId = row.appId;
    if (local == null && appId != null) {
      // Written from here, but the app stopped before keeping the page id.
      final mine = await bank.txnByUid(appId);
      if (mine != null && mine.notionPageId == null) local = mine;
    }
    final plan = planRow(row, since: since);
    final link = BankTxnsCompanion(
      notionPageId: Value(row.pageId),
      notionEditedAt: Value(row.editedAt),
      syncState: local?.syncState == null
          ? const Value(SyncState.synced)
          : const Value.absent(),
    );

    if (local == null) {
      if (plan is! LedgerEntry) return;
      final (account, inbox) = _target(plan, accounts);
      // A page copied in Notion carries the App ID of the one it was
      // copied from.
      final free = appId != null && await bank.txnByUid(appId) == null;
      final created = row.createdAt.millisecondsSinceEpoch == 0
          ? clock.now()
          : row.createdAt;
      await bank.insertTxn(
        BankTxnsCompanion.insert(
          uid: free ? appId : bank.newUid(),
          kind: plan.income ? TxnKind.income : TxnKind.expense,
          fromId: Value(plan.income ? null : account),
          toId: Value(plan.income ? account : null),
          amount: plan.amount,
          day: plan.day,
          at: created,
          title: Value(plan.title),
          note: Value(plan.note),
          category: Value(plan.category),
          inbox: Value(inbox),
          notionPageId: Value(row.pageId),
          notionEditedAt: Value(row.editedAt),
          syncState: const Value(SyncState.synced),
        ),
      );
      return;
    }

    final mine = appId != null && appId == local.uid;
    if (plan is LedgerSkip) {
      // A page in the trash takes its row out of the bank. Otherwise rows
      // written here stay whatever the page turns into, rows from Notion
      // leave the bank with it, and rows from an earlier link are kept.
      final drop =
          local.voidedAt == null &&
          (row.trashed || (!mine && !plan.beforeTheLink));
      await bank.patchTxn(
        local.id,
        drop
            ? link.copyWith(
                voidedAt: Value(clock.now()),
                syncState: const Value(SyncState.trashed),
              )
            : link,
      );
      return;
    }
    // Filed here or voided here: the page hears about it first.
    final waiting =
        local.syncState == SyncState.dirty ||
        (local.voidedAt != null && local.syncState != SyncState.trashed);
    if (waiting) {
      if (local.notionPageId == null) await bank.patchTxn(local.id, link);
      return;
    }
    if (plan is! LedgerEntry) return;

    final (account, inbox) = _target(
      plan,
      accounts,
      current: plan.income ? local.toId : local.fromId,
    );
    final kind = plan.income ? TxnKind.income : TxnKind.expense;
    final from = plan.income ? null : account;
    final to = plan.income ? account : null;
    final same =
        local.notionPageId == row.pageId &&
        local.voidedAt == null &&
        local.kind == kind &&
        local.fromId == from &&
        local.toId == to &&
        local.amount == plan.amount &&
        local.day == plan.day &&
        local.title == plan.title &&
        local.note == plan.note &&
        local.category == plan.category &&
        local.inbox == inbox;
    if (same) return;
    await bank.patchTxn(
      local.id,
      link.copyWith(
        kind: Value(kind),
        fromId: Value(from),
        toId: Value(to),
        amount: Value(plan.amount),
        day: Value(plan.day),
        title: Value(plan.title),
        note: Value(plan.note),
        category: Value(plan.category),
        inbox: Value(inbox),
        voidedAt: const Value(null),
        syncState: const Value(SyncState.synced),
      ),
    );
  }

  /// The account [plan] goes to, and whether it waits in the inbox (in the
  /// vault) because the account is unknown. A row already in an account of
  /// that name stays there (names can repeat).
  (int, bool) _target(LedgerEntry plan, _Accounts accounts, {int? current}) {
    if (current != null &&
        plan.account != null &&
        accounts.nameOf(current) == plan.account) {
      return (current, false);
    }
    final id = accounts.idOf(plan.account);
    return id == null ? (accounts.vault, true) : (id, false);
  }

  /// Sends the bank's changes: voided rows to the trash, filed rows'
  /// accounts, then new rows. A page Notion turns down is let go so the
  /// rest still go; the first such reason is thrown at the end, to show.
  Future<void> _push(
    NotionClient client,
    NotionLink link,
    DateTime since,
  ) async {
    final accounts = _Accounts(await bank.accounts());
    NotionException? refused;
    Future<void> attempt(
      Future<void> Function() send,
      Value<String> giveUp,
      int id,
    ) async {
      try {
        await send();
      } on NotionException catch (e) {
        if (e.passing) rethrow;
        refused ??= e;
        await bank.patchTxn(id, BankTxnsCompanion(syncState: giveUp));
      }
    }

    for (final row in await bank.txnsToUpdate()) {
      final pageId = row.notionPageId!;
      if (row.voidedAt != null) {
        // Already in the trash or gone: there is nothing left to send.
        try {
          await client.updatePage(pageId, inTrash: true);
        } on NotionException catch (e) {
          if (e.passing) rethrow;
        }
        await bank.patchTxn(
          row.id,
          const BankTxnsCompanion(syncState: Value(SyncState.trashed)),
        );
        continue;
      }
      final income = row.kind == TxnKind.income;
      await attempt(
        () async {
          final page = await client.updatePage(
            pageId,
            properties: ledgerAccount(
              accounts.nameOf(income ? row.toId : row.fromId),
            ),
          );
          await bank.patchTxn(
            row.id,
            BankTxnsCompanion(
              syncState: const Value(SyncState.synced),
              notionEditedAt: Value(LedgerRow.parse(page).editedAt),
            ),
          );
        },
        // The page can't take it; the next pull sets the row by the page.
        const Value(SyncState.synced),
        row.id,
      );
    }

    final fresh = await bank.txnsToCreate(since: since);
    if (fresh.isNotEmpty) {
      final budgets = await _budgets(client, link.budget);
      for (final row in fresh) {
        if (!await _still(since)) return;
        await attempt(
          () => _create(client, link.ledger!, row, accounts, budgets),
          const Value(SyncState.failed),
          row.id,
        );
      }
    }
    if (refused != null) throw refused!;
  }

  /// Makes the page for [row], unless an earlier try made it already.
  Future<void> _create(
    NotionClient client,
    String ledger,
    BankTxnRow row,
    _Accounts accounts,
    Map<String, String> budgets,
  ) async {
    final income = row.kind == TxnKind.income;
    final account = accounts.nameOf(income ? row.toId : row.fromId);
    final category =
        row.category ?? defaultCategory(income: income, account: account);
    Map<String, Object?>? page;
    if (row.syncState == SyncState.creating) {
      // The last try may have made the page and lost the answer.
      final made = await client.queryAll(
        ledger,
        filter: {
          'property': LedgerProps.appId,
          'rich_text': {'equals': row.uid},
        },
      );
      page = made.firstOrNull;
    } else {
      await bank.patchTxn(
        row.id,
        const BankTxnsCompanion(syncState: Value(SyncState.creating)),
      );
    }
    page ??= await client.createPage(
      ledger,
      ledgerPage(
        appId: row.uid,
        income: income,
        amount: row.amount,
        day: row.day,
        title: row.title,
        category: category,
        account: account,
        note: row.note,
        budgetPage: income ? null : budgets[category],
      ),
    );
    await bank.patchTxn(
      row.id,
      BankTxnsCompanion(
        notionPageId: Value('${page['id']}'),
        notionEditedAt: Value(LedgerRow.parse(page).editedAt),
        syncState: const Value(SyncState.synced),
        category: Value(category),
      ),
    );
  }

  /// Budget rows by category, for the 預算項目 relation; empty when the
  /// budget table isn't shared with the integration.
  Future<Map<String, String>> _budgets(
    NotionClient client,
    String? budget,
  ) async {
    if (budget == null) return const {};
    try {
      return {
        for (final page in await client.queryAll(budget))
          pageTitle(page): '${page['id']}',
      };
    } on NotionException catch (e) {
      if (e.notShared) return const {};
      rethrow;
    }
  }
}

final notionSyncProvider = Provider<NotionSync>(
  (ref) => NotionSync(
    db: ref.watch(databaseProvider),
    bank: ref.watch(bankRepoProvider),
    settings: ref.watch(settingsRepoProvider),
    secrets: ref.watch(secretStoreProvider),
    httpClient: ref.watch(httpClientProvider),
    clock: ref.watch(clockProvider),
  ),
);

/// The link as settings hold it; follows every change.
final notionLinkProvider = StreamProvider<NotionLink>(
  (ref) => ref
      .watch(settingsRepoProvider)
      .watch(SettingKeys.notion)
      .map(NotionLink.fromJson),
);

/// Starts a sync without waiting for it; for the UI after a change.
void syncNotionSoon(WidgetRef ref) {
  unawaited(ref.read(notionSyncProvider).sync());
}
