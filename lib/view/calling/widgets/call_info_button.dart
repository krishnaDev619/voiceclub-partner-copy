import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/domain/usecases/calling/get_call_details.dart';
import 'package:voiceclub_partner/view/calling/widgets/call_details_bottom_sheet.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class CallInfoButton extends StatelessWidget {
  final bool isAccepted;
  final String demandName;
  final String callStatLabel;
  final String channelId;
  final bool isGameCall;

  const CallInfoButton({
    super.key,
    required this.isAccepted,
    required this.demandName,
    required this.callStatLabel,
    required this.channelId,
    this.isGameCall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isAccepted,
      child: GestureDetector(
        onTap:
            isGameCall
                ? null
                : () async {
                  try {
                    Get.context?.loaderOverlay.show();
                    final response = await sl<GetCallDetailsUsecase>().call(
                      Params(channelId: channelId),
                    );
                    if (response.data != null && response.error == null) {
                      final callDetails = response.data;
                      Get.bottomSheet(
                        CallDetailsBottomSheet(
                          userName: demandName,
                          totalCalls: (callDetails?.callCount ?? 0)
                              .toStringAsFixed(0),
                          totalCallDuration:
                              callDetails?.totalCallDuration ?? 0,
                          label: callStatLabel,
                          currentCall: ((callDetails?.callCount ?? 0) + 1)
                              .toStringAsFixed(0),
                          durationToConvert: callDetails?.timeToConvert ?? 0,
                        ),
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16.0),
                            topRight: Radius.circular(16.0),
                          ),
                        ),
                        backgroundColor: const Color(0xFFF9F9F9),
                      );
                    }
                  } catch (_) {
                  } finally {
                    Get.context?.loaderOverlay.hide();
                  }
                },
        child: Container(
          margin: const EdgeInsets.only(top: 12.0),
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
          decoration: BoxDecoration(
            color: Get.theme.primaryColor,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline_rounded, color: Colors.white, size: 16.0),
              SizedBox(width: 4.0),
              Text(
                LocaleKeys.liveInfo.tr,
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
