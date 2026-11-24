import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../ai/ai_client.dart';
import '../ai/ai_config.dart';
import '../ai/ai_error.dart';
import '../ai/secret_store.dart';
import '../data/settings_repository.dart';
import 'providers.dart';

final secretStoreProvider = Provider<SecretStore>(
  (ref) => KeychainSecretStore(),
);

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final aiConfigProvider = StreamProvider<AiConfig>(
  (ref) => ref
      .watch(settingsRepoProvider)
      .watch(SettingKeys.aiConfig)
      .map(
        (raw) => raw is Map
            ? AiConfig.fromJson(raw.cast<String, Object?>())
            : const AiConfig(),
      ),
);

/// Builds the client for the configured mode; null for copy-paste and
/// offline modes, which the UI handles itself.
class AiService {
  AiService({
    required this.settings,
    required this.secrets,
    required this.httpClient,
  });

  final SettingsRepository settings;
  final SecretStore secrets;
  final http.Client httpClient;

  Future<AiConfig> config() async {
    final raw = await settings.read(SettingKeys.aiConfig);
    return raw is Map
        ? AiConfig.fromJson(raw.cast<String, Object?>())
        : const AiConfig();
  }

  Future<void> saveConfig(AiConfig config) =>
      settings.write(SettingKeys.aiConfig, config.toJson());

  Future<AiClient?> clientFor(AiConfig config) async {
    switch (config.mode) {
      case AiMode.manual:
      case AiMode.offline:
        return null;
      case AiMode.hosted:
        return const HostedClient();
      case AiMode.claude:
        final key = await secrets.read(SecretKeys.claude);
        if (key == null || key.isEmpty) {
          throw const AiException(AiErrorKind.noKey);
        }
        return ClaudeClient(
          httpClient: httpClient,
          apiKey: key,
          model: config.claudeModel,
        );
      case AiMode.openai:
        if (config.openAiModel.trim().isEmpty) {
          throw const AiException(AiErrorKind.badRequest, '請先填寫模型名稱');
        }
        return OpenAiCompatibleClient(
          httpClient: httpClient,
          baseUrl: config.openAiBaseUrl,
          apiKey: await secrets.read(SecretKeys.openai) ?? '',
          model: config.openAiModel.trim(),
        );
    }
  }
}

final aiServiceProvider = Provider<AiService>(
  (ref) => AiService(
    settings: ref.watch(settingsRepoProvider),
    secrets: ref.watch(secretStoreProvider),
    httpClient: ref.watch(httpClientProvider),
  ),
);
