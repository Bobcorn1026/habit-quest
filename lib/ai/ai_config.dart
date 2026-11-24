import 'package:flutter/foundation.dart';

enum AiMode {
  /// Copy a prompt into any chat AI and paste the reply back. Free.
  manual('複製咒文'),

  /// The user's own Anthropic API key.
  claude('Claude API'),

  /// The user's own key for any OpenAI-compatible endpoint.
  openai('OpenAI 相容 API'),

  /// The app's paid plan (not available yet).
  hosted('付費方案'),

  /// Built-in templates only.
  offline('不使用 AI');

  const AiMode(this.label);
  final String label;
}

/// Claude models the user can pick, best first.
const kClaudeModels = <(String, String)>[
  ('claude-opus-5-5', 'Claude Opus 5.5（預設・文筆最好）'),
  ('claude-sonnet-5-5', 'Claude Sonnet 5.5（較便宜）'),
  ('claude-haiku-5-5', 'Claude Haiku 5.5（最便宜）'),
];

/// Common OpenAI-compatible endpoints.
const kOpenAiPresets = <(String, String, String)>[
  ('OpenAI', 'https://api.openai.com/v1', 'gpt-5'),
  (
    'Google Gemini',
    'https://generativelanguage.googleapis.com/v1beta/openai',
    'gemini-2.5-flash',
  ),
  ('OpenRouter', 'https://openrouter.ai/api/v1', ''),
  ('Ollama（本機）', 'http://localhost:11434/v1', 'llama3.1'),
];

/// Which AI writes quests and chapters. API keys live in the Keychain, not
/// here.
@immutable
class AiConfig {
  const AiConfig({
    this.mode = AiMode.manual,
    this.claudeModel = 'claude-opus-5-5',
    this.openAiBaseUrl = 'https://api.openai.com/v1',
    this.openAiModel = '',
  });

  factory AiConfig.fromJson(Map<String, Object?> json) {
    const d = AiConfig();
    return AiConfig(
      mode:
          AiMode.values.where((m) => m.name == json['mode']).firstOrNull ??
          d.mode,
      claudeModel: kClaudeModels.any((m) => m.$1 == json['claudeModel'])
          ? json['claudeModel'] as String
          : d.claudeModel,
      openAiBaseUrl: (json['openAiBaseUrl'] as String?) ?? d.openAiBaseUrl,
      openAiModel: (json['openAiModel'] as String?) ?? d.openAiModel,
    );
  }

  final AiMode mode;
  final String claudeModel;
  final String openAiBaseUrl;
  final String openAiModel;

  bool get usesApi => mode == AiMode.claude || mode == AiMode.openai;

  Map<String, Object?> toJson() => {
    'mode': mode.name,
    'claudeModel': claudeModel,
    'openAiBaseUrl': openAiBaseUrl,
    'openAiModel': openAiModel,
  };

  AiConfig copyWith({
    AiMode? mode,
    String? claudeModel,
    String? openAiBaseUrl,
    String? openAiModel,
  }) => AiConfig(
    mode: mode ?? this.mode,
    claudeModel: claudeModel ?? this.claudeModel,
    openAiBaseUrl: openAiBaseUrl ?? this.openAiBaseUrl,
    openAiModel: openAiModel ?? this.openAiModel,
  );
}
