import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/ai_providers.dart';
import '../../pixel/pixel.dart';
import '../../widgets/pixel_controls.dart';

/// A secret typed or pasted once and kept in the Keychain; shows only
/// whether one is saved.
class SecretKeyField extends ConsumerStatefulWidget {
  const SecretKeyField({
    super.key,
    required this.secretKey,
    required this.hint,
    this.name = 'API key',
    this.saveLabel = '儲存 key',
    this.onSaved,
  });
  final String secretKey;
  final String hint;

  /// What the secret is called on the page.
  final String name;
  final String saveLabel;

  /// After a save or delete.
  final VoidCallback? onSaved;

  @override
  ConsumerState<SecretKeyField> createState() => _SecretKeyFieldState();
}

class _SecretKeyFieldState extends ConsumerState<SecretKeyField> {
  final _c = TextEditingController();
  bool? _saved;

  @override
  void initState() {
    super.initState();
    ref.read(secretStoreProvider).read(widget.secretKey).then((v) {
      if (mounted) setState(() => _saved = v != null && v.isNotEmpty);
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _save(String? value) async {
    await ref.read(secretStoreProvider).write(widget.secretKey, value);
    _c.clear();
    if (!mounted) return;
    setState(() => _saved = value != null && value.isNotEmpty);
    showPixelToast(
      context,
      value == null ? '${widget.name} 已刪除' : '${widget.name} 已存進鑰匙圈',
    );
    widget.onSaved?.call();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _saved == true
              ? '${widget.name}：已儲存（存在系統鑰匙圈，不會上傳）'
              : '${widget.name}：尚未設定',
          style: text.bodySmall,
        ),
        const SizedBox(height: 6),
        PixelTextField(controller: _c, hint: widget.hint, obscure: true),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: PixelButton(
                expand: true,
                onPressed: () {
                  final v = _c.text.trim();
                  if (v.isNotEmpty) _save(v);
                },
                child: Text(widget.saveLabel),
              ),
            ),
            if (_saved == true) ...[
              const SizedBox(width: 8),
              PixelButton(
                tone: PixelButtonTone.danger,
                onPressed: () => _save(null),
                child: const Text('刪除'),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
