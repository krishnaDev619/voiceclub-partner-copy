import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/view/tutorial/demo/controllers/demo_landing_controller.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class DemoChatFilterBottomSheet extends StatelessWidget {
  const DemoChatFilterBottomSheet({super.key});

  void _goBack() {
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final demoController = Get.find<DemoLandingController>();
    return SafeArea(
      child: Obx(() {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
                child: GestureDetector(
                  onTap: () {
                    _goBack();
                  },
                  child: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 20.0, bottom: 24.0),
              width: MediaQuery.of(context).size.width,
              decoration: const ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0, bottom: 8.0),
                      child: Text(
                        LocaleKeys.demoSelectChatFilter.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: FontSize.xL,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const Divider(),
                  for (final filter in demoController.filterOptions)
                    ListTile(
                      visualDensity: VisualDensity.compact,
                      onTap: () {
                        _goBack();
                        demoController.switchChatFilter(filter);
                      },
                      leading: Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Icon(filter.icon, color: Colors.black),
                      ),
                      title: Text(
                        filter.name ?? '',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        filter.description ?? '',
                        style: TextStyle(
                          fontSize: FontSize.M,
                          color: const Color(
                            0xFF3D3D3D,
                          ).withValues(alpha: 0.75),
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.black,
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
