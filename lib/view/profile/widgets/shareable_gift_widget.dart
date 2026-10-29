import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/data/models/rewards/claimed_gifts.dart';
import 'package:voiceclub_partner/data/models/rewards/gifts.dart';

class ShareableGiftWidget extends StatelessWidget {
  final ClaimedGifts gift;
  final RewardGift? rewardGift;

  const ShareableGiftWidget({
    super.key,
    required this.gift,
    required this.rewardGift,
  });

  String get getShareTitle {
    switch (gift.type) {
      case GiftType.CASH:
        return "Reward Received 🎉 !!!";
      case GiftType.GIFT:
        return "Reward Received 🎉 !!!";
      default:
        return "Reward Received 🎉 !!!";
    }
  }

  String get getRewardAmount {
    switch (gift.type) {
      case GiftType.CASH:
        return "₹${rewardGift?.cashAmount?.toStringAsFixed(0) ?? '0'} Cash Bonus";
      case GiftType.GIFT:
        return rewardGift?.title ?? "Gift Received";
      default:
        return "₹${rewardGift?.cashAmount?.toStringAsFixed(0) ?? '0'} Cash Bonus";
    }
  }

  Widget _buildGiftImage() {
    if (gift.type == GiftType.GIFT && rewardGift?.imagePath != null) {
      return FastCachedImage(
        url: rewardGift!.imagePath!,
        width: 200,
        height: 150,
        fit: BoxFit.contain,
        loadingBuilder:
            (context, url) => Container(
              width: 200,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: CircularProgressIndicator()),
            ),
        errorBuilder:
            (context, url, error) => Container(
              width: 200,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.card_giftcard,
                size: 60,
                color: Colors.grey,
              ),
            ),
      );
    } else {
      // For cash bonus, show money/cash icon
      return Container(
        width: 200,
        height: 150,
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(
            Icons.account_balance_wallet,
            size: 80,
            color: Color(0xFF4CAF50),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 500,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Gift boxes on left and right
          Positioned(
            left: 0,
            bottom: 0,
            child: Image.asset(
              AssetConstants.giftLeft,
              width: 100,
              height: 150,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Image.asset(
              AssetConstants.giftRight,
              width: 100,
              height: 150,
              fit: BoxFit.contain,
            ),
          ),

          // Main content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // VoiceClub Logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(AssetConstants.logoHorizontal, height: 50),
                  ],
                ),

                const SizedBox(height: 20),

                // Reward amount/title
                Text(
                  getRewardAmount,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Title
                Text(
                  getShareTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4CAF50),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),

                // Gift/Cash Image
                _buildGiftImage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
