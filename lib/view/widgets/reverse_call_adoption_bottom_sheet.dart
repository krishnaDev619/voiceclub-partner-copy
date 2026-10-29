import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/modules/bindings/reverse_call_list_binding.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/rewards/daily_rewards/widgets/reverse_call_listing.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class ReverseCallAdoptionBottomSheet extends StatelessWidget {
  const ReverseCallAdoptionBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    sl<AnalyticsService>().trackEvent('reverseCallAdoptionBottomSheet');
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              Get.back();
            },
            child: const CircleAvatar(
              backgroundColor: Colors.black38,
              child: Icon(Icons.close),
            ),
          ),
          const SizedBox(height: 10.0),
          Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              ),
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  "Are you not getting calls?",
                  style: TextStyle(
                    fontSize: FontSize.xL,
                    fontWeight: Weight.heavy,
                  ),
                ),
                const SizedBox(height: 6.0),
                SvgPicture.asset(AssetConstants.callAdoptionBg),
                const SizedBox(height: 8.0),
                CustomButton(
                  text: LocaleKeys.liveCallNow.tr,
                  onTap: () async {
                    Get.back();
                    await Get.find<UserController>().getOnlineDuration();
                    Get.to(
                      () => const ReverseCallListing(),
                      binding: ReverseCallListBinding(),
                    );
                    sl<AnalyticsService>().trackEvent(
                      'reverseCallAdoptionCallNowTap',
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
