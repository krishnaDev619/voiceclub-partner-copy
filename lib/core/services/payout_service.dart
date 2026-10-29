import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/url_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/domain/usecases/wallet/get_recent_payout.dart';
import 'package:voiceclub_partner/modules/controller/wallet_controller.dart';
import 'package:voiceclub_partner/view/wallet/widgets/recent_payout_bottom_sheet.dart';
import 'package:voiceclub_partner/view/wallet/widgets/shareable_payout_widget.dart';
import 'package:voiceclub_partner/view/profile/widgets/shareable_gift_widget.dart';
import 'package:voiceclub_partner/data/models/rewards/claimed_gifts.dart';
import 'package:voiceclub_partner/data/models/rewards/gifts.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

class PayoutService {
  static const String _lastShownTransactionIdKey =
      'recent_payout_last_shown_transaction_id';

  static Future<int?> getLastShownTransactionId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lastShownTransactionIdKey);
  }

  static Future<void> updateLastShownTransactionId(int transactionId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastShownTransactionIdKey, transactionId);
  }

  static Future<bool> shouldShowForTransactionId(int? transactionId) async {
    // If transaction ID is null, show the bottom sheet
    if (transactionId == null) return true;

    final int? lastShownId = await getLastShownTransactionId();

    // If no previous ID stored, show the bottom sheet
    if (lastShownId == null) return true;

    // Show only if the transaction ID has changed
    return lastShownId != transactionId;
  }

  Future<void> showRecentPayout() async {
    try {
      final walletController = Get.find<WalletController>();

      final response = await sl<GetRecentPayoutUseCase>().call(NoParams());
      if (response.data != null) {
        final payout = response.data;
        final transactionId = payout?.iD;

        // Check if we should show the bottom sheet for this transaction ID
        final shouldShow = await PayoutService.shouldShowForTransactionId(
          transactionId,
        );
        if (!shouldShow) return;

        // If payout is null, don't show the bottom sheet
        if (payout == null) return;

        if (payout.type != TransactionType.Withdrawal) return;

        // Update the stored transaction ID
        if (transactionId != null) {
          await PayoutService.updateLastShownTransactionId(transactionId);
        }

        if (Get.context == null) return;
        Get.bottomSheet(
          RecentPayoutBottomSheet(
            recentPayout: payout,
            payoutCount:
                walletController.payoutCountResponse.value.payoutCount ?? 0,
          ),
          isScrollControlled: true,
        );
      }
    } catch (e) {
      Logger.logMessage("Error while showing recent payout ${e.toString()}");
    }
  }

  Future<void> sharePayout({
    required num amount,
    required BuildContext context,
  }) async {
    try {
      Get.context?.loaderOverlay.show();

      final WidgetsToImageController captureController =
          WidgetsToImageController();

      // Create a temporary overlay with the shareable widget
      OverlayEntry? overlayEntry;
      overlayEntry = OverlayEntry(
        builder:
            (context) => Positioned(
              left: -1000, // Position off-screen
              top: -1000,
              child: Material(
                color: Colors.transparent,
                child: WidgetsToImage(
                  controller: captureController,
                  child: ShareablePayoutWidget(
                    amount: amount.toDouble(),
                    title: 'Payout Completed!',
                  ),
                ),
              ),
            ),
      );

      Overlay.of(context).insert(overlayEntry);

      // Wait a moment for the widget to render
      await Future.delayed(const Duration(milliseconds: 500));

      // Capture the widget as an image using widgets_to_image
      final Uint8List? imageBytes = await captureController.capture(
        options: CaptureOptions(pixelRatio: 3.0, waitForAnimations: true),
      );

      // Remove the overlay
      overlayEntry.remove();

      final text =
          "Check out my payout on VC Listener App!\nI received ₹${amount.toStringAsFixed(2)} 🎉\n${URLConstants.playStoreUrl}";
      ShareResult? result;
      if (imageBytes != null) {
        // Write image bytes to a temporary file
        final File imageFile = await _writeImageToFile(imageBytes);
        // Share the image file
        final params = ShareParams(files: [XFile(imageFile.path)], text: text);
        result = await SharePlus.instance.share(params);
      } else {
        // Fallback to text sharing if image capture fails
        final params = ShareParams(text: text);
        result = await SharePlus.instance.share(params);
      }
      sl<AnalyticsService>().trackEvent(
        "shareRecentPayout",
        eventProperties: {
          'amount': amount,
          'status': result.status.name,
          'raw': result.raw,
        },
      );
    } catch (e) {
      // Handle any errors
      Logger.logMessage('Error sharing payout: $e');
    } finally {
      Get.context?.loaderOverlay.hide();
    }
  }

  Future<void> shareGift({
    required ClaimedGifts gift,
    required RewardGift? rewardGift,
    required BuildContext context,
  }) async {
    try {
      Get.context?.loaderOverlay.show();

      final WidgetsToImageController captureController =
          WidgetsToImageController();

      // Create a temporary overlay with the shareable widget
      OverlayEntry? overlayEntry;
      overlayEntry = OverlayEntry(
        builder:
            (context) => Positioned(
              left: -1000, // Position off-screen
              top: -1000,
              child: Material(
                color: Colors.transparent,
                child: WidgetsToImage(
                  controller: captureController,
                  child: ShareableGiftWidget(
                    gift: gift,
                    rewardGift: rewardGift,
                  ),
                ),
              ),
            ),
      );

      Overlay.of(context).insert(overlayEntry);

      // Wait a moment for the widget to render
      await Future.delayed(const Duration(milliseconds: 500));

      // Capture the widget as an image using widgets_to_image
      final Uint8List? imageBytes = await captureController.capture(
        options: CaptureOptions(pixelRatio: 3.0, waitForAnimations: true),
      );

      // Remove the overlay
      overlayEntry.remove();

      String shareText;
      if (gift.type == GiftType.CASH) {
        shareText =
            "Check out my reward on VC Listener App!\nI received ₹${rewardGift?.cashAmount?.toStringAsFixed(0) ?? '0'} Cash Bonus 🎉\n${URLConstants.playStoreUrl}";
      } else {
        shareText =
            "Check out my reward on VC Listener App!\nI received ${rewardGift?.title ?? 'a gift'} 🎉\n${URLConstants.playStoreUrl}";
      }

      ShareResult? result;
      if (imageBytes != null) {
        // Write image bytes to a temporary file
        final File imageFile = await _writeImageToFile(imageBytes, 'gift');
        // Share the image file
        final params = ShareParams(
          files: [XFile(imageFile.path)],
          text: shareText,
        );
        result = await SharePlus.instance.share(params);
      } else {
        // Fallback to text sharing if image capture fails
        final params = ShareParams(text: shareText);
        result = await SharePlus.instance.share(params);
      }

      sl<AnalyticsService>().trackEvent(
        "shareReward",
        eventProperties: {
          'giftType': gift.type?.name,
          'amount': rewardGift?.cashAmount,
          'giftTitle': rewardGift?.title,
          'status': result.status.name,
          'raw': result.raw,
        },
      );
    } catch (e) {
      // Handle any errors
      Logger.logMessage('Error sharing gift: $e');
    } finally {
      Get.context?.loaderOverlay.hide();
    }
  }

  Future<File> _writeImageToFile(
    Uint8List imageBytes, [
    String prefix = 'payout',
  ]) async {
    try {
      // Get temporary directory
      final Directory tempDir = await getTemporaryDirectory();

      // Create a unique filename with timestamp
      final String fileName =
          '${prefix}_${DateTime.now().millisecondsSinceEpoch}.png';
      final String filePath = '${tempDir.path}/$fileName';

      // Write the image bytes to the file
      final File imageFile = File(filePath);
      await imageFile.writeAsBytes(imageBytes);

      Logger.logMessage('Image saved to: $filePath');
      return imageFile;
    } catch (e) {
      Logger.logMessage('Error writing image to file: $e');
      rethrow;
    }
  }
}
