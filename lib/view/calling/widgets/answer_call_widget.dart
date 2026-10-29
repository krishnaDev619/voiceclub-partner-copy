import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/view/calling/widgets/decline_call_dialog.dart';
import 'package:voiceclub_partner/view/widgets/rounded_button.dart';

class AnswerCallWidget extends StatelessWidget {
  final bool isNew;
  final void Function() onAccept;
  final void Function() onReject;
  final int? rejectedCallCount;
  final bool isLifeTimeCallBannerActive;

  const AnswerCallWidget({
    super.key,
    required this.isNew,
    required this.onAccept,
    required this.onReject,
    required this.rejectedCallCount,
    required this.isLifeTimeCallBannerActive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          RoundedButton(
            size: 64.0,
            press: () {
              Get.dialog(
                DeclineCallDialog(
                  rejectedCallCount: rejectedCallCount ?? 0,
                  isNew: isNew,
                  leaveFunction: onReject,
                ),
              );
            },
            color: Colors.red,
            iconColor: Colors.white,
            iconSrc: AssetConstants.callEnd,
          ),
          RoundedButton(
            size: 64.0,
            press: onAccept,
            color: ApplicationColors.green,
            iconColor: Colors.white,
            iconSrc: AssetConstants.callEnd,
          ),
        ],
      ),
    );
  }
}
