import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class NotificationSwitchBottomSheet extends StatefulWidget {
  const NotificationSwitchBottomSheet({super.key});

  @override
  State<NotificationSwitchBottomSheet> createState() =>
      _NotificationSwitchBottomSheetState();
}

class _NotificationSwitchBottomSheetState
    extends State<NotificationSwitchBottomSheet> {
  final userController = Get.find<UserController>();

  void _goBack() {
    Get.back<bool>();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              _goBack();
            });
          }
        },
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
                      userController.isNotificationsEnabled
                          ? LocaleKeys.liveNotificationOff.tr
                          : LocaleKeys.liveNotificationOn.tr,
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
                          userController.isNotificationsEnabled
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                      width: 90.0,
                      height: 40.0,
                      padding: const EdgeInsets.all(3.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(48.0),
                        color:
                            userController.isNotificationsEnabled
                                ? const Color(0xFFFF3131)
                                : const Color(0xFF00D54F),
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
                            text:
                                userController.isNotificationsEnabled
                                    ? LocaleKeys
                                        .liveNotificationOffDescription
                                        .tr
                                    : LocaleKeys
                                        .liveNotificationOnDescription
                                        .tr,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: FontSize.xL),
                    ),
                    const SizedBox(height: 12.0),
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
                              userController.updateNotificationPreference();
                              _goBack();
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
