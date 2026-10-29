import 'package:flutter/material.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:get/get.dart';

class NoAuthQueryChatBottomBar extends StatefulWidget {
  final bool enabled;
  final Future<bool> Function(String message) onSend;

  const NoAuthQueryChatBottomBar({
    super.key,
    required this.enabled,
    required this.onSend,
  });

  @override
  State<NoAuthQueryChatBottomBar> createState() =>
      _NoAuthQueryChatBottomBarState();
}

class _NoAuthQueryChatBottomBarState extends State<NoAuthQueryChatBottomBar> {
  final _messageController = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _messageController.text.trim().isNotEmpty;
    if (hasText != _hasText && mounted) {
      setState(() => _hasText = hasText);
    }
  }

  Future<void> _send() async {
    if (!widget.enabled || !_hasText) return;

    final sent = await widget.onSend(_messageController.text);
    if (sent) _messageController.clear();
  }

  @override
  void dispose() {
    _messageController
      ..removeListener(_onTextChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSend = widget.enabled && _hasText;
    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        8,
        12,
        MediaQuery.viewInsetsOf(context).bottom + 12,
      ),
      color: const Color(0xFFFFF6E0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _messageController,
                enabled: widget.enabled,
                minLines: 1,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: LocaleKeys.liveMessage.tr,
                  isCollapsed: true,
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: canSend ? _send : null,
            child: Container(
              width: 44,
              height: 44,
              padding: const EdgeInsets.only(left: 3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(
                  0xFF1EAB61,
                ).withValues(alpha: canSend ? 1 : 0.45),
              ),
              child: Transform.rotate(
                angle: 5.5,
                child: const Icon(
                  Icons.send_rounded,
                  color: ApplicationColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
