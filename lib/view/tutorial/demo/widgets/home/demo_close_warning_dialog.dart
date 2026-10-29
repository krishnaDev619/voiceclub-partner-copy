import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class DemoCloseWarningDialog extends StatelessWidget {
  const DemoCloseWarningDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(AssetConstants.goBackWarningImage),
            const SizedBox(height: 10.0),
            Text(
              LocaleKeys.demoAreYouSure.tr,
              style: TextStyle(fontWeight: Weight.heavy, fontSize: FontSize.xL),
            ),
            const SizedBox(height: 10.0),
            Text(
              LocaleKeys.demoProgressDeleted.tr,
              style: TextStyle(
                fontWeight: Weight.heavy,
                color: Color(0xFF949494),
              ),
            ),
            const SizedBox(height: 10.0),
            CustomButton(
              text: LocaleKeys.demoYesGoToCourses.tr,
              onTap: () {
                Get.back(result: true);
              },
            ),
            const SizedBox(height: 10.0),
            CustomButton(
              text: LocaleKeys.demoNo.tr,
              onTap: () {
                Get.back(result: false);
              },
              filled: false,
            ),
          ],
        ),
      ),
    );
  }
}
