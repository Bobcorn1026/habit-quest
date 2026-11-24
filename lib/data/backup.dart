import 'dart:convert';

import 'database.dart';

/// Tag that marks a JSON file as one of our backups.
const kBackupFormat = 'habit_quest-backup';

class BackupException implements Exception {
  const BackupException(this.message);

  /// Shown to the player as is.
  final String message;

  @override
  String toString() => message;
}

/// A parsed, checked backup, ready to restore.
class Backup {
  const Backup({required this.exportedAt, required this.tables});

  final DateTime? exportedAt;

  /// Raw SQL rows keyed by table name.
  final Map<String, List<Map<String, Object?>>> tables;

  Map<String, int> get counts => {
    for (final e in tables.entries) e.key: e.value.length,
  };
}

/// Whole-database backups as JSON. Rows are copied as raw SQL values, so a
/// backup survives changes to Dart types as long as the schema matches.
/// API keys live in the Keychain and are never included.
class BackupService {
  BackupService(this._db);
  final AppDatabase _db;

  /// Parents before children, so restoring respects foreign keys.
  static const tableOrder = [
    'adventurers',
    'habits',
    'quests',
    'check_ins',
    'xp_events',
    'gold_events',
    'purchases',
    'price_weeks',
    'focus_weeks',
    'focus_sessions',
    'bank_accounts',
    'bank_txns',
    'bank_months',
    'casino_weeks',
    'casino_tickets',
    'chapters',
    'upgrade_offers',
    'settings',
  ];

  Future<String> export(DateTime now) async {
    final tables = <String, Object?>{};
    for (final t in tableOrder) {
      final rows = await _db.customSelect('SELECT * FROM "$t"').get();
      tables[t] = [for (final r in rows) r.data];
    }
    return jsonEncode({
      'format': kBackupFormat,
      'version': 1,
      'schemaVersion': _db.schemaVersion,
      'exportedAt': now.toIso8601String(),
      'tables': tables,
    });
  }

  /// Parses and checks [text] without touching the database.
  Backup inspect(String text) {
    Object? json;
    try {
      json = jsonDecode(text);
    } on FormatException {
      json = null;
    }
    if (json is! Map || json['format'] != kBackupFormat) {
      throw const BackupException('這個檔案不是勇者日課的備份檔。');
    }
    final schema = json['schemaVersion'];
    if (schema is! int || schema > _db.schemaVersion) {
      throw const BackupException('這份備份來自較新版本的 app，請先更新再還原。');
    }
    final raw = json['tables'];
    if (raw is! Map) throw const BackupException('備份檔內容不完整。');

    final columns = {
      for (final t in _db.allTables)
        t.actualTableName: {for (final c in t.$columns) c.name},
    };
    final tables = <String, List<Map<String, Object?>>>{};
    for (final MapEntry(:key, :value) in raw.entries) {
      final known = columns[key];
      if (known == null || value is! List) {
        throw BackupException('備份檔裡有不認得的資料表：$key。');
      }
      final rows = <Map<String, Object?>>[];
      for (final row in value) {
        if (row is! Map) throw BackupException('資料表 $key 的格式不對。');
        for (final c in row.keys) {
          if (!known.contains(c)) {
            throw BackupException('資料表 $key 有不認得的欄位：$c。');
          }
        }
        rows.add(row.cast<String, Object?>());
      }
      tables[key as String] = rows;
    }
    return Backup(
      exportedAt: DateTime.tryParse('${json['exportedAt']}'),
      tables: tables,
    );
  }

  /// Replaces everything in the database with [backup].
  Future<void> restore(Backup backup) async {
    await _db.transaction(() async {
      for (final t in tableOrder.reversed) {
        await _db.customStatement('DELETE FROM "$t"');
      }
      for (final t in tableOrder) {
        for (final row in backup.tables[t] ?? const []) {
          final cols = row.keys.toList();
          await _db.customStatement(
            'INSERT INTO "$t" (${cols.map((c) => '"$c"').join(', ')}) '
            'VALUES (${List.filled(cols.length, '?').join(', ')})',
            [for (final c in cols) row[c]],
          );
        }
      }
    });
    _db.markTablesUpdated(_db.allTables);
  }

  /// Empties every table, so the app starts over as on its first launch.
  /// The Keychain (API keys) is not touched.
  Future<void> wipe() => restore(const Backup(exportedAt: null, tables: {}));
}
