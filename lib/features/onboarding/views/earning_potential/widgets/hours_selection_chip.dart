import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class HoursSelectionChip extends StatelessWidget {
  final int hours;
  final bool selected;
  final VoidCallback onTap;

  const HoursSelectionChip({
    super.key,
    required this.hours,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80.0,
      height: 50.0,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: selected ? Get.theme.primaryColor : const Color(0xFFEDEDED),
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.all(6.0),
          margin: const EdgeInsets.all(4.0),
          child: Center(
            child: FittedBox(
              child: Text(
                LocaleKeys.hoursChip.trParams({'hours': '$hours'}),
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF797979),
                  fontSize: FontSize.xXL,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
