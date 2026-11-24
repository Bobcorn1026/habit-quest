import 'dart:io';
import 'dart:ui';

import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

/// Moves backup files in and out of the app.
abstract interface class BackupFiles {
  /// Hands [content] to the share sheet as a file called [name] (save to
  /// Files, AirDrop…). [origin] anchors the popover on iPad. False when the
  /// player cancels.
  Future<bool> save(String name, String content, {Rect? origin});

  /// Lets the player pick a backup file; null when cancelled.
  Future<String?> open();
}

const _json = XTypeGroup(
  label: 'JSON',
  extensions: ['json'],
  uniformTypeIdentifiers: ['public.json'],
);

class SystemBackupFiles implements BackupFiles {
  @override
  Future<bool> save(String name, String content, {Rect? origin}) async {
    final dir = await Directory.systemTemp.createTemp('backup');
    final file = File('${dir.path}/$name');
    await file.writeAsString(content);
    final result = await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/json')],
        sharePositionOrigin: origin,
      ),
    );
    return result.status == ShareResultStatus.success;
  }

  @override
  Future<String?> open() async {
    final file = await openFile(acceptedTypeGroups: const [_json]);
    return file?.readAsString();
  }
}

final backupFilesProvider = Provider<BackupFiles>((ref) => SystemBackupFiles());
