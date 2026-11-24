enum AiErrorKind {
  noKey,
  auth,
  rateLimit,
  overloaded,
  network,
  refusal,
  truncated,
  badRequest,
  badResponse,
  unavailable,
}

/// A failure talking to an AI, with a message fit to show the player.
class AiException implements Exception {
  const AiException(this.kind, [this.detail = '']);

  final AiErrorKind kind;
  final String detail;

  String get message => switch (kind) {
    AiErrorKind.noKey => '還沒有設定 API key。請到「角色 → 設定」貼上你的 key。',
    AiErrorKind.auth => 'API key 無效或已失效，請到設定檢查。',
    AiErrorKind.rateLimit => '呼叫太頻繁或額度用完了，請稍後再試。',
    AiErrorKind.overloaded => 'AI 服務暫時忙碌，請稍後再試。',
    AiErrorKind.network => '連不上 AI 服務，請檢查網路。',
    AiErrorKind.refusal => 'AI 拒絕了這次請求。可以改用「複製咒文」模式再試一次。',
    AiErrorKind.truncated => 'AI 的回覆被截斷了，請再試一次。',
    AiErrorKind.badRequest => 'AI 服務不接受這次請求。',
    AiErrorKind.badResponse => 'AI 的回覆格式不對。',
    AiErrorKind.unavailable => '付費方案即將推出，目前請使用其他模式。',
  };

  @override
  String toString() => detail.isEmpty ? message : '$message（$detail）';
}
