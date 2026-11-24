import 'dart:convert';

import '../domain/story_config.dart';
import 'database.dart';

abstract final class SettingKeys {
  static const storyConfig = 'story_config';
  static const aiConfig = 'ai_config';
  static const worldBible = 'world_bible';
  static const onboarded = 'onboarded';
  static const storyFont = 'story_font';
  static const reminders = 'reminders';

  /// Curses judged since the board last showed them.
  static const curseNews = 'curse_news';

  /// Mentor tips already shown, by id.
  static const tipsSeen = 'tips_seen';

  /// Title frame and board wood from the shop.
  static const equipped = 'equipped';

  /// The training ground as the player set it up (`FocusSettings`).
  static const focus = 'focus';

  /// When the break after a focus session ends (ISO 8601); null when there
  /// is no break.
  static const focusBreak = 'focus_break';

  /// The system brightness to put back if the app dies while the
  /// power-saving view has dimmed the screen.
  static const focusRestoreBrightness = 'focus_restore_brightness';

  /// The bank's monthly numbers as the player set them (`BankConfig`).
  static const bank = 'bank';

  /// The vault's amount is covered up.
  static const bankHidden = 'bank_hidden';

  /// The link to the Notion ledger (`NotionLink`); the token is in the
  /// Keychain.
  static const notion = 'notion';
}

/// Small JSON values keyed by name. Never stores secrets.
class SettingsRepository {
  SettingsRepository(this._db);
  final AppDatabase _db;

  Future<Object?> read(String key) async {
    final row = await (_db.select(
      _db.settings,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row == null ? null : jsonDecode(row.value);
  }

  Stream<Object?> watch(String key) =>
      (_db.select(_db.settings)..where((t) => t.key.equals(key)))
          .watchSingleOrNull()
          .map((row) => row == null ? null : jsonDecode(row.value));

  Future<void> write(String key, Object? value) => _db
      .into(_db.settings)
      .insertOnConflictUpdate(
        SettingsCompanion.insert(key: key, value: jsonEncode(value)),
      );

  Future<StoryConfig> storyConfig() async {
    final raw = await read(SettingKeys.storyConfig);
    return raw is Map
        ? StoryConfig.fromJson(raw.cast<String, Object?>())
        : const StoryConfig();
  }

  Stream<StoryConfig> watchStoryConfig() => watch(SettingKeys.storyConfig).map(
    (raw) => raw is Map
        ? StoryConfig.fromJson(raw.cast<String, Object?>())
        : const StoryConfig(),
  );

  Future<void> saveStoryConfig(StoryConfig config) =>
      write(SettingKeys.storyConfig, config.toJson());
}
