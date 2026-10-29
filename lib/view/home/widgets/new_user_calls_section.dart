import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class NewUserCallsSection extends StatelessWidget {
  const NewUserCallsSection({super.key});

  String formatCallLimit(int? callCount, int? limit) {
    final count = callCount ?? 0;
    final maxLimit = limit ?? 0;

    return "${count > maxLimit ? maxLimit : count}/$maxLimit";
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final data = Get.find<UserController>().userDetails.value;
      return Visibility(
        visible: data.showCallCount ?? false,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(
            right: 16.0,
            left: 16.0,
            top: 10.0,
            bottom: 10.0,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4.0,
                spreadRadius: 0.4,
              ),
            ],
          ),
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaleKeys.homeNewUser.tr,
                    style: TextStyle(
                      fontWeight: Weight.heavy,
                      fontSize: FontSize.xL,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    LocaleKeys.homeUpdatesDaily.tr,
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.5),
                      fontSize: FontSize.M,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20.0),
              Expanded(
                child: LinearProgressIndicator(
                  value: (data.callCount ?? 0) / (data.limit ?? 0),
                  backgroundColor: const Color(
                    0xffD9D9D9,
                  ).withValues(alpha: 0.4),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF348800),
                  ),
                  minHeight: 14.0,
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              const SizedBox(width: 10.0),
              Text(
                formatCallLimit(data.callCount, data.limit),
                style: const TextStyle(
                  fontSize: FontSize.xXL,
                  fontWeight: Weight.heavy,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
