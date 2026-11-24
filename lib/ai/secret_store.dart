import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract final class SecretKeys {
  static const claude = 'claude_api_key';
  static const openai = 'openai_api_key';

  /// The Notion internal integration's token.
  static const notion = 'notion_token';
}

/// Where API keys live. Never in the database or settings JSON.
abstract interface class SecretStore {
  Future<String?> read(String key);
  Future<void> write(String key, String? value);
}

/// The system Keychain.
class KeychainSecretStore implements SecretStore {
  final _storage = const FlutterSecureStorage();

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String? value) =>
      value == null || value.isEmpty
      ? _storage.delete(key: key)
      : _storage.write(key: key, value: value);
}

class MemorySecretStore implements SecretStore {
  final _values = <String, String>{};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String? value) async {
    if (value == null || value.isEmpty) {
      _values.remove(key);
    } else {
      _values[key] = value;
    }
  }
}
