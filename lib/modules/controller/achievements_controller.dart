import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/data/models/rewards/get_gifts.dart';
import 'package:voiceclub_partner/data/models/rewards/gifts.dart';
import 'package:voiceclub_partner/domain/usecases/rewards/get_gifts.dart';
import 'package:voiceclub_partner/domain/usecases/wallet/get_milestone_earnings.dart';
import 'package:voiceclub_partner/view/profile/widgets/gift_selection_bottom_sheet.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class AchievementsController extends GetxController {
  final isLoading = false.obs;

  final yearlyEarning = 0.obs;
  final lifetimeEarning = 0.obs;

  final gifts = GetGiftsResponse().obs;

  final shouldShowYearlyNext = false.obs;
  final shouldShowLifetimeNext = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  Future<void> fetch() async {
    isLoading(true);
    try {
      await Future.wait([_fetchMilestoneEarnings(), _fetchGifts()]);
      computeAndShowGiftSelectionBottomSheet();
      _computeDerived();
    } catch (_) {
      // no-op
    } finally {
      isLoading(false);
    }
  }

  Future<void> _fetchMilestoneEarnings() async {
    final res = await sl<GetMilestoneEarningsUsecase>().call(NoParams());
    if (res.data != null && res.error == null) {
      yearlyEarning((res.data!.yearly ?? 0).floor());
      lifetimeEarning((res.data!.lifetime ?? 0).floor());
    } else {
      AlertService.showSnackBar(
        snackBarType: SnackBarType.Error,
        title: LocaleKeys.liveCouldNotFetchEarnings.tr,
        subtitle: LocaleKeys.pleaseTryAgainLater.tr,
      );
    }
  }

  Future<void> _fetchGifts() async {
    final res = await sl<GetGiftsUseCase>().call(NoParams());
    if (res.data != null && res.error == null) {
      gifts(res.data!);
    }
  }

  void computeAndShowGiftSelectionBottomSheet() {
    RewardGift? nearestGift =
        gifts.value.gifts
            ?.where((gift) => yearlyEarning.value >= (gift.targetEarnings ?? 0))
            .lastOrNull;

    if (nearestGift != null &&
        gifts.value.claimedGifts?.any((e) => e.giftId == nearestGift.id) ==
            false &&
        nearestGift.type == GiftType.GIFT) {
      // Show gift selection bottom sheet for physical gifts
      Get.bottomSheet(
        GiftSelectionBottomSheet(gift: nearestGift, isFromHomeScreen: true),
        isDismissible: true,
        enableDrag: false,
      );
    }
  }

  void _computeDerived() {
    final yearlyNextTarget = _getNextYearlyTarget(yearlyEarning.value);
    shouldShowYearlyNext(
      yearlyNextTarget != null &&
          (yearlyNextTarget - yearlyEarning.value) <= 3000,
    );

    final lifetimeNextTarget = _getNextLifetimeTarget(lifetimeEarning.value);
    shouldShowLifetimeNext(
      lifetimeNextTarget != null &&
          (lifetimeNextTarget - lifetimeEarning.value) <= 3000,
    );
  }

  int? _getNextYearlyTarget(int current) {
    final list = gifts.value.gifts;
    if (list == null || list.isEmpty) return null;
    for (final g in list) {
      final target = (g.targetEarnings ?? 0).toInt();
      if (current < target) return target;
    }
    return null;
  }

  int? _getNextLifetimeTarget(int current) {
    for (final gift in LifetimeRewardGift.values) {
      if (current < gift.targetEarnings) return gift.targetEarnings;
    }
    return null;
  }
}
