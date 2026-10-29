import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class StatusSwitchBottomSheet extends StatelessWidget {
  final bool online;
  final String durationHours;
  final String durationMinutes;
  final int requiredDurationInHours;

  const StatusSwitchBottomSheet({
    super.key,
    required this.online,
    required this.durationHours,
    required this.durationMinutes,
    required this.requiredDurationInHours,
  });

  void _goBack({bool value = false}) {
    Get.back<bool>(result: value);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            _goBack();
          });
        }
      },
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, right: 4.0),
                  child: GestureDetector(
                    onTap: () {
                      _goBack();
                    },
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12.0),
                width: MediaQuery.of(context).size.width,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16.0),
                    Text(
                      online ? 'ONLINE' : 'OFFLINE',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: FontSize.xXXL,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12.0),
                      alignment:
                          online ? Alignment.centerRight : Alignment.centerLeft,
                      width: 90.0,
                      height: 40.0,
                      padding: const EdgeInsets.all(3.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(48.0),
                        color:
                            online
                                ? const Color(0xFF00D54F)
                                : const Color(0xFFFF3131),
                      ),
                      child: Container(
                        width: 32.0,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: LocaleKeys.liveAreYouSureYouWant4.tr,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: FontSize.xL,
                            ),
                          ),
                          TextSpan(
                            text: online ? 'online?' : 'offline?',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12.0),
                    if (!online)
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: LocaleKeys.liveRequiredOnlineDuration.tr,
                            ),
                            TextSpan(
                              text: LocaleKeys.liveHoursNeeded.trParams({
                                'hours': '$requiredDurationInHours',
                              }),
                              style: const TextStyle(fontWeight: Weight.heavy),
                            ),
                            TextSpan(
                              text: LocaleKeys.liveCurrentOnlineDuration.tr,
                            ),
                            TextSpan(
                              text:
                                  "$durationHours Hours $durationMinutes Minutes",
                              style: const TextStyle(fontWeight: Weight.heavy),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: LocaleKeys.liveNo.tr,
                            onTap: () {
                              _goBack();
                            },
                            filled: false,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: CustomButton(
                            text: LocaleKeys.liveYes.tr,
                            onTap: () {
                              _goBack(value: true);
                            },
                            filled: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
