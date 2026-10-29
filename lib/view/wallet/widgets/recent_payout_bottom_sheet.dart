import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/services/payout_service.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/data/models/wallet/get_payout_breakdown.dart';
import 'package:voiceclub_partner/data/models/wallet/result_wallet.dart';
import 'package:voiceclub_partner/modules/controller/wallet_controller.dart';
import 'package:voiceclub_partner/view/wallet/widgets/payout_details_bottom_sheet.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class RecentPayoutBottomSheet extends StatelessWidget {
  final ResultWalletModel recentPayout;
  final int payoutCount;

  const RecentPayoutBottomSheet({
    super.key,
    required this.recentPayout,
    required this.payoutCount,
  });

  String _formatPayoutRange(String? dateString) {
    final date = DateTime.tryParse(dateString ?? '')?.toLocal();
    if (date == null) return '';
    final previousDate = date.subtract(const Duration(days: 10));
    return "${DateFormat('dd MMM yyyy').format(previousDate)} - ${DateFormat('dd MMM yyyy').format(date)}";
  }

  Future<void> _showPayoutBreakdown({
    required int transactionId,
    required String createdAt,
  }) async {
    try {
      Get.context?.loaderOverlay.show();
      final walletController = Get.find<WalletController>();
      final GetPayoutBreakdownResponse? payoutBreakdown = await walletController
          .getPayoutBreakdown(transactionId);
      if (payoutBreakdown != null) {
        Get.back();
        Get.bottomSheet(
          PayoutDetailsBottomsheet(
            payoutBreakdown: payoutBreakdown,
            createdAt: createdAt,
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
    } catch (e) {
      Logger.logMessage(
        "Error while fetching payout breakdown ${e.toString()}",
      );
    } finally {
      Get.context?.loaderOverlay.hide();
    }
  }

  void _fireAnalytics() {
    try {
      sl<AnalyticsService>().trackEvent(
        "recentPayoutBottomSheet",
        eventProperties: {
          "amount": recentPayout.getAmount ?? recentPayout.paymentValue ?? 0,
          "payoutCount": payoutCount,
          "payoutDate": recentPayout.createdAt,
        },
      );
    } catch (e) {
      Logger.logMessage(
        "Error while firing analytics for recent payout bottom sheet ${e.toString()}",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _fireAnalytics();
    final amount = recentPayout.getAmount ?? recentPayout.paymentValue ?? 0;
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Lottie.asset(
                AssetConstants.payoutSuccess,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              "₹${amount.toStringAsFixed(2)}",
              style: const TextStyle(
                color: Color(0xFF2DAA2F),
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Payout Completed!',
              style: TextStyle(
                fontSize: FontSize.L,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20.0),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Details',
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.8),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 14.0,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(LocaleKeys.homePayoutDate.tr),
                      Text(_formatPayoutRange(recentPayout.createdAt)),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(LocaleKeys.livePayoutCount.tr),
                      Text('$payoutCount'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFFF6F63),
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        side: const BorderSide(
                          color: Color(0xFFFF6F63),
                          width: 1.0,
                        ),
                      ),
                    ),
                    onPressed: () {
                      sl<PayoutService>().sharePayout(
                        amount: amount,
                        context: context,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.share, size: 18),
                        SizedBox(width: 8),
                        Text(LocaleKeys.liveShare.tr),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6F63),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    onPressed: () {
                      final id = recentPayout.iD ?? 0;
                      final createdAt = recentPayout.createdAt ?? '';
                      _showPayoutBreakdown(
                        transactionId: id,
                        createdAt: createdAt,
                      );
                    },
                    child: Text(LocaleKeys.liveViewDetails.tr),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }
}
