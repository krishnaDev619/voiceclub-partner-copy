// ignore_for_file: avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/core/disabled_widget.dart';
import 'package:voiceclub_partner/view/widgets/debounce_widget.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class ActivityStatusWidget extends StatefulWidget {
  const ActivityStatusWidget({super.key});

  @override
  State<ActivityStatusWidget> createState() => _ActivityStatusWidgetState();
}

class _ActivityStatusWidgetState extends State<ActivityStatusWidget> {
  Debounce? debounce;

  @override
  void initState() {
    debounce = Debounce(millisecond: 300);
    super.initState();
  }

  @override
  void dispose() {
    debounce?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Disabled(
      disabled: false,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(
          top:
              !(Get.find<UserController>().userDetails.value.kycCompleted ??
                      false)
                  ? 12.0
                  : 16.0,
          left: 16.0,
          right: 16.0,
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
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          LocaleKeys.homeActiveStatus.tr,
                          style: TextStyle(
                            fontWeight: Weight.heavy,
                            fontSize: FontSize.xL,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      LocaleKeys.homeGoOnline.tr,
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
                child: GetBuilder<UserController>(
                  builder: (controller) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              debounce?.run(() {
                                controller.showUpdateStatusBottomSheet(false);
                              });
                            },
                            child: Container(
                              height: double.infinity,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color:
                                    controller.isOnlineOrBusy
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
                                  LocaleKeys.homeOffline.tr,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: FontSize.M,
                                    color:
                                        controller.isOnlineOrBusy
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
                            color:
                                controller.isBusy
                                    ? const Color(0xFFF9DCA4)
                                    : Colors.white,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                LocaleKeys.homeBusy.tr,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: FontSize.M,
                                  color:
                                      controller.isBusy
                                          ? Colors.black
                                          : Colors.black45,
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
                              debounce?.run(() {
                                controller.showUpdateStatusBottomSheet(true);
                              });
                            },
                            child: Container(
                              height: double.infinity,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color:
                                    controller.isOnline
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
                                  LocaleKeys.homeOnline.tr,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: FontSize.M,
                                    color:
                                        controller.isOnline
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
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
