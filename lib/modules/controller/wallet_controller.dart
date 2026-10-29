import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/growthbook_service.dart';
import 'package:voiceclub_partner/core/services/hyperverge_service.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/data/models/wallet/get_payout_breakdown.dart';
import 'package:voiceclub_partner/data/models/wallet/payout_count.dart';
import 'package:voiceclub_partner/data/models/wallet/result_wallet.dart';
import 'package:voiceclub_partner/data/models/wallet/transaction_details.dart';
import 'package:voiceclub_partner/domain/usecases/wallet/fetch_transcations.dart'
    as fetch_transactions_use_case;
import 'package:voiceclub_partner/domain/usecases/wallet/get_coin_balance.dart';
import 'package:voiceclub_partner/domain/usecases/wallet/get_milestone_earnings.dart';
import 'package:voiceclub_partner/domain/usecases/wallet/get_payout_breakdown.dart'
    as get_payout_breakdown;
import 'package:voiceclub_partner/domain/usecases/wallet/get_payout_count.dart';
import 'package:voiceclub_partner/domain/usecases/wallet/get_transaction_details.dart'
    as get_transaction_details_use_case;
import 'package:voiceclub_partner/domain/usecases/wallet/get_wallet_detail.dart'
    as wallet_detail_use_case;
import 'package:voiceclub_partner/domain/usecases/wallet/withdraw_payout.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/milestone/milestone_rewards_screen.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class WalletController extends GetxController {
  Rx<double> finalValue = 0.0.obs;
  Rx<double> giftAmount = 0.0.obs;
  final coinBalance = 0.0.obs;
  final transactions = <ResultWalletModel>{}.obs;
  final isLoading = false.obs; // Loading state variable
  int _totalPages = 1;
  final selectedTransactionTab = TransactionCategory.ALL.obs;
  final payoutCountResponse = PayoutCountResponse().obs;

  final _fetchTransactionsUseCase =
      sl<fetch_transactions_use_case.FetchTranscationsUseCase>();
  final _getWalletDetailUseCase =
      sl<wallet_detail_use_case.GetWalletDetailUsecase>();
  final _transactionDetailsUseCase =
      sl<get_transaction_details_use_case.GetTransactionDetailsUseCase>();
  final _getPayoutBreakdownUseCase =
      sl<get_payout_breakdown.GetPayoutBreakdownUseCase>();

  @override
  void onInit() {
    fetchCoinBalance();
    getPayoutCount();
    super.onInit();
  }

  Future fetchData() async {
    try {
      var response = await _getWalletDetailUseCase.call(NoParams());
      finalValue.value = response.data?.totalValue?.toDouble() ?? 0.0;
      giftAmount.value = response.data?.giftAmount?.toDouble() ?? 0.0;
      update();
      sl<AnalyticsService>().updateSupplyBalance(finalValue.value);
    } catch (_) {}
  }

  Future fetchCoinBalance() async {
    try {
      var response = await sl<GetCoinBalanceUseCase>().call(NoParams());
      coinBalance.value = response.data?.amountRemaining?.toDouble() ?? 0.0;
      update();
    } catch (_) {}
  }

  Future<TransactionDetailsModel?> getTransactionDetails(int id) async {
    try {
      final response = await _transactionDetailsUseCase.call(
        get_transaction_details_use_case.Params(id: id),
      );
      if (response.data != null && response.error == null) {
        return response.data;
      } else {
        return null;
      }
    } catch (_) {
      return null;
    }
  }

  Future<GetPayoutBreakdownResponse?> getPayoutBreakdown(int id) async {
    try {
      final response = await _getPayoutBreakdownUseCase.call(
        get_payout_breakdown.Params(id: id),
      );
      if (response.data != null && response.error == null) {
        return response.data;
      } else {
        return null;
      }
    } catch (e) {
      Logger.logMessage(
        "Error while fetching payout breakdown ${e.toString()}",
      );
      return null;
    }
  }

  void getWalletTransactionFetch(
    int page, {
    required TransactionCategory transactionCategory,
    bool isInit = false,
  }) async {
    try {
      // Check if there are more pages to fetch
      if (page == 1) {
        if (!isInit) {
          transactions.clear();
        }
        _totalPages = 1;
      }
      if (page <= _totalPages) {
        isLoading.value = true; // Set loading state to true
        var response = await _fetchTransactionsUseCase.call(
          fetch_transactions_use_case.Params(
            category: CategoryOption.ALL,
            transactionType: transactionCategory,
            page: page,
            pageSize: 25,
          ),
        );
        // Add fetched transactions to the list
        transactions.addAll(response.data?.resultWalletList ?? []);
        _totalPages = response.data?.totalPages ?? _totalPages;
      }
    } catch (_) {
    } finally {
      update();
      isLoading.value = false;
    }
  }

  void fetchAndShowMiletoneEarnings({
    int selectedTabIndex = 0,
    bool isFromHomeScreen = false,
  }) async {
    try {
      Get.context?.loaderOverlay.show();
      final response = await sl<GetMilestoneEarningsUsecase>().call(NoParams());
      if (response.data != null) {
        final yearly = (response.data?.yearly ?? 0).floor();
        final lifetime = (response.data?.lifetime ?? 0).floor();
        Get.to(
          () => MilestoneRewardsScreen(
            currentYearlyEarning: yearly,
            currentLifetimeEarning: lifetime,
            selectedTabIndex: selectedTabIndex,
            isFromHomeScreen: isFromHomeScreen,
          ),
        );
      } else {
        AlertService.showSnackBar(
          snackBarType: SnackBarType.Error,
          title: LocaleKeys.liveCouldNotFetchRewards.tr,
          subtitle: LocaleKeys.pleaseTryAgainLater.tr,
        );
      }
    } catch (e) {
      AlertService.showSnackBar(
        snackBarType: SnackBarType.Error,
        title: LocaleKeys.liveSomethingWentWrong.tr,
        subtitle: LocaleKeys.liveTryAgainWithError.trParams({
          'detail': e.toString(),
        }),
      );
    } finally {
      Get.context?.loaderOverlay.hide();
    }
  }

  void changeTransactionTab(TransactionCategory newCategory) {
    if (selectedTransactionTab.value != newCategory) {
      selectedTransactionTab(newCategory);
      update();
      getWalletTransactionFetch(1, transactionCategory: newCategory);
    }
  }

  Future<void> getPayoutCount() async {
    try {
      final response = await sl<GetPayoutCountUseCase>().call(NoParams());
      if (response.data != null) {
        payoutCountResponse(response.data);
      }
    } catch (e) {
      Logger.logMessage("Error in getPayoutCount ${e.toString()}");
    } finally {
      update();
    }
  }

  Future<void> withdrawPayout() async {
    try {
      // Get user details from UserController
      final userController = Get.find<UserController>();
      final userData = userController.userDetails.value;

      if (userController.isAgencyPartner ||
          !userController.enablePayoutWithdraw) {
        return;
      }

      // Check if user is eligible for Aadhar eSign but hasn't completed it
      final isAadharSignEligible = userData.aadharSignEligible ?? false;
      final isAadharSignDone = userData.aadharSignDone ?? false;
      final isFlagEnabled = sl<GrowthBookService>().isFeatureEnabled(
        FeatureFlag.newkycflow,
      );

      if (isAadharSignEligible && !isAadharSignDone && isFlagEnabled) {
        // Show KYC completion dialog
        final kycResult = await Get.dialog<bool?>(
          AlertDialog(
            title: Text(LocaleKeys.liveCompleteKycRequired.tr),
            content: const Text(
              'To withdraw your payout, you need to complete the Aadhar eSign verification process first. This is a one-time requirement to ensure secure transactions.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back(result: false);
                },
                child: Text(LocaleKeys.cancel.tr),
              ),
              ElevatedButton(
                onPressed: () {
                  Get.back(result: true);
                },
                child: Text(LocaleKeys.liveStartKyc.tr),
              ),
            ],
          ),
          barrierDismissible: false,
        );

        if (kycResult == true) {
          // Launch Aadhar eSign process
          final phoneNumber = userData.user?.phoneNumber;
          if (phoneNumber != null && phoneNumber.isNotEmpty) {
            await HypervergeKYCService.launchAadharSign(phone: phoneNumber);
          } else {
            AlertService.showSnackBar(
              snackBarType: SnackBarType.Error,
              title: LocaleKeys.errorTitle.tr,
              subtitle: LocaleKeys.livePhoneNumberNotFoundPlease.tr,
            );
          }
        }
        return;
      }

      // Proceed with normal withdrawal flow
      final result = await Get.dialog<bool?>(
        AlertDialog(
          title: Text(LocaleKeys.liveWithdrawPayout.tr),
          content: Text(LocaleKeys.liveAreYouSureYouWant2.tr),
          actions: [
            TextButton(
              onPressed: () {
                Get.back(result: false);
              },
              child: Text(LocaleKeys.cancel.tr),
            ),
            ElevatedButton(
              onPressed: () async {
                Get.back(result: true);
              },
              child: Text(LocaleKeys.liveWithdraw.tr),
            ),
          ],
        ),
        barrierDismissible: false,
      );

      if (result == true) {
        try {
          Get.context?.loaderOverlay.show();
          final response = await sl<WithdrawPayoutUseCase>().call(NoParams());
          if (response.error != null) {
            AlertService.showSnackBar(
              snackBarType: SnackBarType.Error,
              title: LocaleKeys.errorTitle.tr,
              subtitle: response.errorMessage,
            );
          } else {
            fetchData();
            AlertService.showSnackBar(
              snackBarType: SnackBarType.Success,
              title: LocaleKeys.liveSuccess.tr,
              subtitle: LocaleKeys.livePayoutWithdrawalInitiatedSuccessfully.tr,
            );
          }
        } catch (e) {
          Logger.logMessage("Error in withdrawPayout ${e.toString()}");
          AlertService.showSnackBar(
            snackBarType: SnackBarType.Error,
            title: LocaleKeys.errorTitle.tr,
            subtitle: LocaleKeys.liveFailedToWithdrawPayoutPlease.tr,
          );
        } finally {
          Get.context?.loaderOverlay.hide();
          update();
        }
      }
    } catch (e) {
      Logger.logMessage("Error in withdrawPayout ${e.toString()}");
      AlertService.showSnackBar(
        snackBarType: SnackBarType.Error,
        title: LocaleKeys.errorTitle.tr,
        subtitle: LocaleKeys.liveSomethingWentWrongPleaseTry.tr,
      );
    }
  }
}
