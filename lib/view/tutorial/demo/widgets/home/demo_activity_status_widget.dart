import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/view/tutorial/demo/controllers/demo_landing_controller.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class DemoActivityStatusWidget extends StatelessWidget {
  const DemoActivityStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DemoLandingController>();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4.0, spreadRadius: 0.4),
        ],
      ),
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaleKeys.demoActiveStatus.tr,
                    style: TextStyle(
                      fontWeight: Weight.heavy,
                      fontSize: FontSize.xL,
                    ),
                  ),
                  Text(
                    LocaleKeys.demoGoOnline.tr,
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.5),
                      fontSize: FontSize.M,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Container(
              height: 30.0,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Obx(() {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          controller.showUpdateStatusBottomSheet(false);
                        },
                        child: Container(
                          height: double.infinity,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color:
                                controller.isOnline.value
                                    ? Colors.white
                                    : Colors.red,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(30),
                              bottomLeft: Radius.circular(30),
                            ),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              LocaleKeys.demoOffline.tr,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: FontSize.M,
                                color:
                                    controller.isOnline.value
                                        ? Colors.black45
                                        : Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(
                      child: Container(
                        height: double.infinity,
                        width: double.infinity,
                        color: Colors.white,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            LocaleKeys.demoBusy.tr,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: FontSize.M,
                              color: Colors.black45,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          controller.showUpdateStatusBottomSheet(true);
                        },
                        child: Container(
                          height: double.infinity,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color:
                                controller.isOnline.value
                                    ? const Color(0xFF4AA611)
                                    : Colors.white,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              LocaleKeys.demoOnline.tr,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: FontSize.M,
                                color:
                                    controller.isOnline.value
                                        ? Colors.white
                                        : Colors.black45,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
