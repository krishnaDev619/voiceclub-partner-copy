import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class StepWidget extends StatelessWidget {
  final int step;
  final String stepName;
  final bool isCurrent;
  final bool completed;
  final void Function() onTap;

  const StepWidget({
    super.key,
    required this.step,
    required this.stepName,
    required this.isCurrent,
    required this.completed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.stepNumber.trParams({'step': '$step'}),
          style: TextStyle(
            color:
                isCurrent || completed
                    ? Get.theme.primaryColor
                    : const Color(0xFFD8D8D8),
            fontWeight: Weight.heavy,
            fontSize: FontSize.L,
          ),
        ),
        const SizedBox(height: 10.0),
        InkWell(
          onTap: () {
            if (isCurrent) {
              onTap();
            }
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE8E8E8)),
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      stepName,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color:
                            isCurrent || completed
                                ? Colors.black
                                : const Color(0xFFD8D8D8),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (completed)
                      Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF4AA611),
                        ),
                        padding: const EdgeInsets.all(2.0),
                        margin: const EdgeInsets.only(right: 4.0),
                        child: const Icon(Icons.done, color: Colors.white),
                      ),
                    if (step != 3)
                      Icon(
                        Icons.chevron_right,
                        color:
                            isCurrent || completed
                                ? Colors.black
                                : const Color(0xFFD8D8D8),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
