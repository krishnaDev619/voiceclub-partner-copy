import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';

class PendingGiftDialog extends StatelessWidget {
  final String claimedAt;
  const PendingGiftDialog({super.key, required this.claimedAt});

  /// Calculates the expected date when the gift will be received
  /// If claimed in current month, payment will be on 5th of next month
  /// If claimed in previous month, payment will be on 5th of current month
  String get expectedPaymentDate {
    final DateTime claimedDate = DateTime.parse(claimedAt);
    final DateTime now = DateTime.now();

    if (claimedDate.month == now.month && claimedDate.year == now.year) {
      return "5 ${_getMonthName(now.month + 1)}, ${now.year} to 15 ${_getMonthName(now.month + 1)}, ${now.year}";
    } else {
      return "5 ${_getMonthName(now.month)}, ${now.year} to 15 ${_getMonthName(now.month + 1)}, ${now.year}";
    }
  }

  /// Helper method to convert month number to month name
  String _getMonthName(int month) {
    const monthNames = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];

    return monthNames[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(AssetConstants.pending, width: 100, height: 100),
            const SizedBox(height: 24),
            Text(
              LocaleKeys.livePending.tr,
              style: const TextStyle(
                fontSize: FontSize.xXXL,
                fontWeight: Weight.bold,
                color: Color(0xFFFFD700), // Golden yellow color
              ),
            ),
            const SizedBox(height: 16),
            Text(
              LocaleKeys.liveClaimRequestPending.trParams({
                'date': expectedPaymentDate,
              }),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: FontSize.xXL,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
