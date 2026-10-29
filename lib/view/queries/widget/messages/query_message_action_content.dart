import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:voiceclub_partner/data/models/query/action_choice.dart';
import 'package:voiceclub_partner/data/models/query/query_message_model.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:get/get.dart';

/// Inline actions below a received TEXT message: date picker, time picker, or
/// API-driven single choice (radio). Sends the chosen value as plain text.
class QueryMessageActionContent extends StatefulWidget {
  final QueryMessageModel message;
  final Future<void> Function(
    String content,
    String? actionOptionType,
    String? actionValue,
    int? externalId,
  )
  onSend;

  /// When true, skips the outer card so this sits inside the parent message bubble.
  final bool embeddedInBubble;

  const QueryMessageActionContent({
    super.key,
    required this.message,
    required this.onSend,
    this.embeddedInBubble = false,
  });

  @override
  State<QueryMessageActionContent> createState() =>
      _QueryMessageActionContentState();
}

class _QueryMessageActionContentState extends State<QueryMessageActionContent> {
  static const _accent = Color(0xFF25D366);

  bool _sending = false;
  String? _selectedChoiceValue;

  String get _normalized => widget.message.actionType?.trim() ?? "";

  bool get _isDate => _normalized.toUpperCase() == 'DATE';

  bool get _isTime => _normalized.toUpperCase() == 'TIME';

  @override
  void initState() {
    super.initState();
  }

  Future<void> _guardSend(
    String content, {
    String? actionOptionType,
    String? actionValue,
    int? externalId,
  }) async {
    if (_sending || content.trim().isEmpty) return;
    setState(() => _sending = true);
    try {
      await widget.onSend(
        content.trim(),
        actionOptionType,
        actionValue,
        externalId,
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _pickDate() async {
    if (_sending) return;
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _accent,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null || !mounted) return;
    final formatted = DateFormat.yMMMd().format(picked);
    await _guardSend(formatted);
  }

  Future<void> _pickTime() async {
    if (_sending) return;
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _accent,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null || !mounted) return;
    final formatted = picked.format(context);
    await _guardSend(formatted);
  }

  Future<void> _sendChoice(ActionChoice choice) async {
    if (_sending) return;
    final value = (choice.value ?? '').trim();
    if (value.isEmpty) return;
    setState(() => _selectedChoiceValue = value);
    final label = (choice.label ?? '').trim();
    await _guardSend(
      label,
      actionOptionType: choice.optionType,
      actionValue: choice.value,
      externalId: choice.externalId,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_sending) {
      // return Padding(
      //   padding: EdgeInsets.only(top: widget.embeddedInBubble ? 6 : 10),
      //   child: const Center(
      //     child: SizedBox(
      //       width: 22,
      //       height: 22,
      //       child: CircularProgressIndicator(strokeWidth: 2, color: _accent),
      //     ),
      //   ),
      // );
      return SizedBox.shrink();
    }

    final body = _buildBody(context);

    if (widget.embeddedInBubble) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 6),
            child: Divider(
              height: 1,
              thickness: 1,
              color: Colors.black.withValues(alpha: 0.08),
            ),
          ),
          body,
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 6),
          child: Divider(
            height: 1,
            thickness: 1,
            color: Colors.black.withValues(alpha: 0.08),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: body,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isDate) {
      return _actionButton(
        icon: Icons.calendar_today_outlined,
        label: LocaleKeys.liveChooseDate.tr,
        onTap: _pickDate,
      );
    }
    if (_isTime) {
      return _actionButton(
        icon: Icons.schedule_outlined,
        label: LocaleKeys.liveChooseTime.tr,
        onTap: _pickTime,
      );
    }
    return _buildChoicesSection(context);
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return FilledButton.tonal(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        foregroundColor: const Color(0xFF2F2F2F),
        backgroundColor: const Color(0xFFE8F8EC),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: _accent),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildChoicesSection(BuildContext context) {
    if (widget.message.actionChoices == null ||
        widget.message.actionChoices!.isEmpty) {
      return SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.liveSelectOneOption.tr,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),
        ...widget.message.actionChoices!.map((choice) {
          final value = (choice.value ?? '').trim();
          final label = (choice.label ?? '').trim();
          final selected = _selectedChoiceValue == value;
          final choiceColor = choice.flutterColor;
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _sending ? null : () => _sendChoice(choice),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: choiceColor.withValues(alpha: 0.14),
                    border: Border.all(
                      color: choiceColor.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        selected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        size: 22,
                        color: selected ? choiceColor : Colors.grey.shade500,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.25,
                            color: Color(0xFF2F2F2F),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
