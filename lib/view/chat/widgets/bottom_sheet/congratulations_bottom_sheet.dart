import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/modules/controller/chat_overview_controller.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class CongratulationsBottomSheet extends StatelessWidget {
  final String supplyName, avatar;
  const CongratulationsBottomSheet({
    super.key,
    required this.supplyName,
    required this.avatar,
  });

  void _goBack() {
    Get.find<ChatOverviewController>().fetchChats(page: 1);
    Get.back(closeOverlays: true);
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
              padding: const EdgeInsets.symmetric(
                vertical: 28.0,
                horizontal: 12.0,
              ),
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
                  CircleAvatar(
                    radius: 40,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: const Color(0xFF5DBBFF),
                      backgroundImage: FastCachedImageProvider(avatar),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Congratulations!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: FontSize.xXXL,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: LocaleKeys.liveYouVeNowUpgradedChat.tr,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: FontSize.L,
                          ),
                        ),
                        TextSpan(
                          text: supplyName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
