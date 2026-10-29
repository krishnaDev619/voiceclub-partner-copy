import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/payout_service.dart';
import 'package:voiceclub_partner/data/models/rewards/claimed_gifts.dart';
import 'package:voiceclub_partner/data/models/rewards/gifts.dart';
import 'package:voiceclub_partner/view/widgets/gradient_text.dart';

class ClaimedGiftDialog extends StatelessWidget {
  final ClaimedGifts gift;
  final RewardGift? rewardGift;

  const ClaimedGiftDialog({
    super.key,
    required this.gift,
    required this.rewardGift,
  });

  String get getGiftTitle {
    switch (gift.type) {
      case GiftType.CASH:
        return LocaleKeys.liveReceivedCashAddedToWallet.tr;
      case GiftType.GIFT:
        return LocaleKeys.liveReceivedGiftAsGift.trParams({
          'gift': rewardGift?.title ?? '',
        });
      default:
        return LocaleKeys.liveReceivedCashAddedToWallet.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: Colors.white,
        ),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            SvgPicture.asset(AssetConstants.congratulationsBg),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 32.0),
                  child: GradientText(
                    LocaleKeys.liveCongratulations.tr,
                    gradient: Gradients.primaryGradient(),
                    style: const TextStyle(
                      fontWeight: Weight.bold,
                      fontSize: FontSize.xXL,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 16.0,
                  ),
                  child: Text(
                    getGiftTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF5B5B5B)),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      AssetConstants.congratulationsGirl,
                      height: 160.0,
                      width: 160.0,
                      fit: BoxFit.contain,
                    ),
                    Visibility(
                      visible: gift.type == GiftType.GIFT,
                      replacement: Image.asset(
                        AssetConstants.money,
                        height: 110.0,
                        width: 100.0,
                        fit: BoxFit.contain,
                      ),
                      child: FastCachedImage(
                        url: rewardGift?.imagePath ?? '',
                        height: 110.0,
                        width: 100.0,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
                // Share button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        sl<PayoutService>().shareGift(
                          gift: gift,
                          rewardGift: rewardGift,
                          context: context,
                        );
                      },
                      icon: const Icon(
                        Icons.share,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: Text(
                        LocaleKeys.liveShareYourReward.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6F63),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14.0,
                          horizontal: 24.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
