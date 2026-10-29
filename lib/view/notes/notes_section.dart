import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/data/models/chat/chat_theme.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class NotesSection extends StatelessWidget {
  final ChatTheme theme;
  const NotesSection({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(10.0),
          bottomLeft: Radius.circular(10.0),
        ),
        color: Colors.white,
      ),
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                LocaleKeys.liveYourNotes.tr,
                style: const TextStyle(
                  fontWeight: Weight.heavy,
                  fontSize: FontSize.xL,
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.primaryColor.withValues(alpha: 0.10),
            ),
            padding: const EdgeInsets.all(6.0),
            child: Icon(Icons.add, color: theme.primaryColor),
          ),
        ],
      ),
    );
  }
}
