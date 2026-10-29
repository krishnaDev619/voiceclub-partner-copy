import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/view/widgets/rounded_button.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class CallEndButton extends StatelessWidget {
  final void Function()? onEndSuccess;
  final void Function()? onEndFail;
  final double size;
  const CallEndButton({
    super.key,
    required this.onEndSuccess,
    required this.onEndFail,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return RoundedButton(
      size: size,
      press: () {
        Get.dialog(
          AlertDialog(
            title: Text(
              LocaleKeys.liveDeclineCallConfirm.tr,
              style: const TextStyle(fontSize: 13),
            ),
            actions: [
              TextButton(
                onPressed: onEndFail,
                child: Text(LocaleKeys.cancel.tr),
              ),
              TextButton(
                onPressed: onEndSuccess,
                child: Text(LocaleKeys.liveYes.tr),
              ),
            ],
          ),
        );
      },
      color: Colors.red,
      iconColor: Colors.white,
      iconSrc: AssetConstants.callEnd,
    );
  }
}
