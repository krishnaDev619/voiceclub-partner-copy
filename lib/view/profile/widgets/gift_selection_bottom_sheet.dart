import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/data/models/rewards/gifts.dart';
import 'package:voiceclub_partner/view/milestone/controllers/milestone_rewards_controller.dart';
import 'package:voiceclub_partner/view/profile/address_info.dart';

class GiftSelectionBottomSheet extends StatelessWidget {
  final RewardGift gift;
  final bool? isFromHomeScreen;

  const GiftSelectionBottomSheet({
    super.key,
    required this.gift,
    this.isFromHomeScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MilestoneRewardsController>();
    sl<AnalyticsService>().trackEvent(
      "milestoneRewardTypePopup",
      eventProperties: {
        "gift": gift.title,
        "isFromHomeScreen": isFromHomeScreen,
      },
    );

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 24 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(AssetConstants.rewardsGiftIc, width: 30, height: 30),
              const SizedBox(width: 8),
              Text(
                'You received a Gift',
                style: TextStyle(
                  fontSize: FontSize.xL,
                  fontWeight: Weight.bold,
                  color: Get.theme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'What do you want?',
            style: TextStyle(fontSize: FontSize.xL, fontWeight: Weight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (gift.id == null) return;
                    Get.to(() => AddressInfoScreen(gift: gift));
                    sl<AnalyticsService>().trackEvent(
                      "milestoneRewardTypeSelected",
                      eventProperties: {
                        "type": "gift",
                        "gift": gift.title,
                        "isFromHomeScreen": isFromHomeScreen,
                      },
                    );
                  },
                  child: Container(
                    height: 160,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: FastCachedImage(url: gift.imagePath ?? ''),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          gift.title ?? 'Gift',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (gift.id == null) return;

                    sl<AnalyticsService>().trackEvent(
                      "milestoneRewardTypeSelected",
                      eventProperties: {
                        "type": "cash",
                        "isFromHomeScreen": isFromHomeScreen,
                      },
                    );

                    controller.claimGift(
                      giftId: gift.id!,
                      type: GiftType.CASH.name,
                      address: '',
                      amount: gift.cashAmount?.toInt() ?? 0,
                    );
                  },
                  child: Container(
                    height: 160,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      children: [
                        Expanded(child: Image.asset(AssetConstants.money)),
                        const SizedBox(height: 8),
                        Text(
                          "₹${gift.cashAmount} cash prize in your wallet.",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
