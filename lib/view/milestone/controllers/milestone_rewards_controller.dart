import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/data/models/rewards/get_gifts.dart';
import 'package:voiceclub_partner/domain/usecases/rewards/claim_gift.dart';
import 'package:voiceclub_partner/domain/usecases/rewards/get_gifts.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class MilestoneRewardsController extends GetxController {
  final gifts = GetGiftsResponse().obs;

  @override
  void onInit() {
    super.onInit();
    fetchGifts();
  }

  Future<void> fetchGifts() async {
    Get.context?.loaderOverlay.show();
    try {
      final result = await sl<GetGiftsUseCase>().call(NoParams());
      if (result.data != null) {
        gifts.value = result.data!;
      }
    } catch (e) {
      Logger.logMessage("Error fetching gifts: $e");
    } finally {
      Get.context?.loaderOverlay.hide();
    }
  }

  Future<void> claimGift({
    required int giftId,
    required String type,
    required String address,
    required int amount,
  }) async {
    try {
      Get.context?.loaderOverlay.show();
      final result = await sl<ClaimGiftUseCase>().call(
        ClaimGiftParams(giftId: giftId, type: type, address: address),
      );
      if (result.error == null) {
        Get.back();
        AlertService.showSnackBar(
          snackBarType: SnackBarType.Success,
          title: LocaleKeys.liveWellDone.tr,
          subtitle: LocaleKeys.liveOurTeamWillContactYou.tr,
        );
        sl<AnalyticsService>().trackEvent(
          "claimGiftSuccess",
          eventProperties: {"giftId": giftId, "type": type, "amount": amount},
        );
      } else {
        AlertService.showSnackBar(
          snackBarType: SnackBarType.Error,
          title: LocaleKeys.errorTitle.tr,
          subtitle:
              result.error?.response?.data['message'] ??
              'Failed to claim gift. Please try again.',
        );
      }
    } catch (e) {
      Logger.logMessage("Error claiming gift: $e");
      AlertService.showSnackBar(
        snackBarType: SnackBarType.Error,
        title: LocaleKeys.errorTitle.tr,
        subtitle: LocaleKeys.liveFailedToClaimGiftPlease.tr,
      );
    } finally {
      Get.context?.loaderOverlay.hide();
    }
  }
}
