import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/data/models/wallet/slab.dart';
import 'package:voiceclub_partner/data/models/wallet/transaction_details.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class DemoTransactionDetailsBottomSheet extends StatelessWidget {
  final TransactionDetailsModel transactionDetails;

  const DemoTransactionDetailsBottomSheet({
    super.key,
    required this.transactionDetails,
  });

  Widget _buildTable() {
    final callDurationInSeconds = transactionDetails.callDuration ?? 0;
    final selectedSlabIndex = findSlabIndex(callDurationInSeconds.ceil());
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        _buildHeader([
          LocaleKeys.demoDuration.tr,
          LocaleKeys.demoEarningsHeader.tr,
        ]),
        for (int i = 0; i < (transactionDetails.slabs?.length ?? 0); i++)
          _buildTableRow(
            transactionDetails.slabs?[i] ?? Slab(),
            i,
            isSelected: selectedSlabIndex == i,
          ),
      ],
    );
  }

  TableRow _buildHeader(List<String?> cells) {
    return TableRow(
      decoration: null,
      children:
          cells.map((cell) {
            return Container(
              alignment:
                  (cell == cells.first)
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              child: FittedBox(
                child: Text(
                  cell ?? '',
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: FontSize.M,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  TableRow _buildTableRow(Slab slab, int index, {bool isSelected = false}) {
    return TableRow(
      decoration:
          isSelected
              ? BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color:
                      transactionDetails.holdStatus == HoldStatus.Hold
                          ? Colors.amber
                          : (transactionDetails.holdStatus == HoldStatus.Lapsed
                              ? Colors.red
                              : ((index == 0) ? Colors.red : Colors.green)),
                ),
                borderRadius: BorderRadius.circular(4.0),
              )
              : null,
      children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: FittedBox(
            child: Text(
              slab.duration,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: FontSize.M,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ),
        Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: FittedBox(
            child: Text(
              (transactionDetails.isPercentage ?? false)
                  ? slab.percentage
                  : slab.split,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: FontSize.M,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String formatTime(int? seconds) {
    return '${(Duration(seconds: seconds ?? 0))}'.split('.')[0].padLeft(8, '0');
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String formatDateTime(String dateTimeString) {
    final dateTime = DateTime.tryParse(dateTimeString)?.toLocal();
    if (dateTime != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));

      String formattedDate = '';

      if (isSameDay(dateTime, today)) {
        formattedDate = LocaleKeys.demoToday.tr;
      } else if (isSameDay(dateTime, yesterday)) {
        formattedDate = LocaleKeys.demoYesterday.tr;
      } else if (now.difference(dateTime).inDays < 7) {
        formattedDate = DateFormat('EEEE').format(dateTime);
      } else if (dateTime.year == now.year) {
        formattedDate = DateFormat('E, dd MMM').format(dateTime);
      } else {
        formattedDate = DateFormat('dd MMM yyyy').format(dateTime);
      }

      final formattedTime = DateFormat('HH:mm').format(dateTime);

      return '$formattedDate $formattedTime';
    } else {
      return "00:00:00";
    }
  }

  int findSlabIndex(int currentCallDuration) {
    final slabs = transactionDetails.slabs ?? [];
    if (slabs.isNotEmpty) {
      int lastIndex = slabs.length - 1;
      for (int i = 0; i < slabs.length; i++) {
        Slab slab = slabs[i];
        if (currentCallDuration >= slab.start! &&
            currentCallDuration <= slab.end!) {
          return i;
        }
      }
      // If currentCallDuration is greater than all slabs, return the index of the last slab
      return lastIndex;
    } else {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                color: Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(LocaleKeys.demoCaller.tr),
                      Container(
                        height: 16.0,
                        constraints: BoxConstraints(maxWidth: Get.width / 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SvgPicture.asset(AssetConstants.avatarIcon),
                            const SizedBox(width: 8.0),
                            Flexible(
                              child: Text(
                                transactionDetails.user?.name ??
                                    LocaleKeys.demoAnon.tr,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(LocaleKeys.demoCallDuration.tr),
                        Text(
                          formatTime(transactionDetails.callDuration?.toInt()),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(LocaleKeys.demoCallStartTime.tr),
                      Text(
                        formatDateTime(transactionDetails.callStartTime ?? ""),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(LocaleKeys.demoCallEndTime.tr),
                      Text(
                        formatDateTime(transactionDetails.callEndTime ?? ""),
                      ),
                    ],
                  ),
                  const Divider(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        LocaleKeys.demoTotalEarning.tr,
                        style: TextStyle(
                          color:
                              transactionDetails.holdStatus == HoldStatus.Hold
                                  ? Colors.amber
                                  : (transactionDetails.holdStatus ==
                                          HoldStatus.Lapsed
                                      ? Colors.red
                                      : Colors.green),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "₹${transactionDetails.amount?.toStringAsFixed(2)}",
                        style: TextStyle(
                          color:
                              transactionDetails.holdStatus == HoldStatus.Hold
                                  ? Colors.amber
                                  : (transactionDetails.holdStatus ==
                                          HoldStatus.Lapsed
                                      ? Colors.red
                                      : Colors.green),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (transactionDetails.holdStatus == HoldStatus.Hold ||
                      transactionDetails.holdStatus == HoldStatus.Lapsed)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        (transactionDetails.holdStatus == HoldStatus.Hold)
                            ? LocaleKeys.demoAmountWithinDay.tr
                            : LocaleKeys.demoDidNotSendAudio.tr,
                        style: TextStyle(
                          color:
                              (transactionDetails.holdStatus == HoldStatus.Hold)
                                  ? Colors.amber
                                  : Colors.red,
                          fontSize: FontSize.M,
                        ),
                      ),
                    ),
                  Visibility(
                    visible: transactionDetails.reason?.isNotEmpty ?? false,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            LocaleKeys.demoCallEndReason.tr,
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(width: 32.0),
                          Text(
                            transactionDetails.reason ?? "",
                            style: TextStyle(
                              color:
                                  transactionDetails.holdStatus ==
                                          HoldStatus.Hold
                                      ? Colors.amber
                                      : (transactionDetails.holdStatus ==
                                              HoldStatus.Lapsed
                                          ? Colors.red
                                          : Colors.green),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Container(
              padding: const EdgeInsets.all(14.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                color: Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: _buildTable(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
