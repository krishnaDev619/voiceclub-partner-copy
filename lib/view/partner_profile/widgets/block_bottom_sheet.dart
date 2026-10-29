import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/avatar_service.dart';
import 'package:voiceclub_partner/domain/usecases/blocking/block_user.dart'
    as block_user_use_case;
import 'package:voiceclub_partner/domain/usecases/blocking/report_user.dart';
import 'package:voiceclub_partner/modules/controller/chat_overview_controller.dart';
import 'package:voiceclub_partner/view/logs/logs_controller.dart';

class BlockProfileBottomSheet extends StatefulWidget {
  const BlockProfileBottomSheet({
    super.key,
    required this.isReport,
    required this.name,
    required this.avatar,
    required this.accountId,
  });

  final bool isReport;
  final String name, avatar;
  final int accountId;

  @override
  State<BlockProfileBottomSheet> createState() =>
      _BlockProfileBottomSheetState();
}

class _BlockProfileBottomSheetState extends State<BlockProfileBottomSheet> {
  BlockReason selectedReason = BlockReason.Other;
  OtherReason selectedOtherReason = OtherReason.personal;

  final _reportUserUseCase = sl<ReportUserUsecase>();
  final _blockUserUseCase = sl<block_user_use_case.BlockUserUsecase>();

  Map<OtherReason, Map<String, String>> otherReasons = {
    OtherReason.personal: {
      'en': 'Asked for Personal Information',
      'hi': 'Apki Personal Information maang raha hai',
    },
    OtherReason.sexual: {
      'en': 'Sexual Conversation',
      'hi': 'Galat/Vulgar baat kar raha hai',
    },
    OtherReason.harassment: {
      'en': 'Harassing on Call',
      'hi': 'Call par pareshan kar raha hai',
    },
  };

  @override
  void initState() {
    super.initState();
  }

  String getReason() {
    if (selectedReason != BlockReason.Other) {
      return selectedReason.name;
    } else {
      return otherReasons[selectedOtherReason]?['en'] ??
          selectedOtherReason.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 42.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                          const SizedBox(width: 4.0),
                          const Icon(Icons.verified, color: Colors.blue),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          'Reason for ${widget.isReport ? 'reporting' : 'blocking'} ${widget.name}?',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                      selectedReason == BlockReason.Other
                          ? Column(
                            children: [
                              for (final other in otherReasons.entries)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedOtherReason = other.key;
                                    });
                                  },
                                  child: Opacity(
                                    opacity:
                                        other.key == selectedOtherReason
                                            ? 1.0
                                            : 0.3,
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(8.0),
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 4.0,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(),
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            other.value.values.first,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12.0,
                                            ),
                                          ),
                                          Text(
                                            other.value.values.last,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 12.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          )
                          : const SizedBox.shrink(),
                      widget.isReport
                          ? const SizedBox.shrink()
                          : const Padding(
                            padding: EdgeInsets.only(top: 16.0),
                            child: Text(
                              '*You can unblock them from Settings.',
                              style: TextStyle(
                                fontWeight: FontWeight.w100,
                                fontSize: 12.0,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                    ],
                  ), // Show check icon
                ),
                Transform.translate(
                  offset: const Offset(0, -60),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Get.theme.primaryColor,
                        backgroundImage: FastCachedImageProvider(
                          widget.avatar.isNotEmpty
                              ? widget.avatar
                              : AvatarService.getRandomAvatarUrl(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12.0),
          GestureDetector(
            onTap: () async {
              String reason = getReason();
              if (widget.isReport) {
                await _reportUserUseCase.call(
                  Params(accountId: widget.accountId, reason: reason),
                );
                sl<AnalyticsService>().trackEvent(
                  'reportSuccess',
                  eventProperties: {
                    'partnerName': widget.name,
                    'partnerAccountId': widget.accountId,
                    'reason': reason,
                  },
                );
              } else {
                await _blockUserUseCase.call(
                  block_user_use_case.Params(
                    accountId: widget.accountId,
                    reason: reason,
                  ),
                );
                sl<AnalyticsService>().trackEvent(
                  'blockSuccessPartner',
                  eventProperties: {
                    'demandName': widget.name,
                    'demandAccountId': widget.accountId,
                    'reason': reason,
                  },
                );
              }
              Get.back(result: true);
              Get.find<ChatOverviewController>().fetchChats(page: 1);
              Get.find<LogsController>().fetchLogs();
              Get.back();
              AlertService.showSnackBar(
                snackBarType: SnackBarType.Success,
                title: widget.isReport ? 'Reported' : 'Blocked',
                subtitle:
                    '${widget.name} was succesfully ${widget.isReport ? 'reported' : 'blocked'}.',
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Get.theme.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.isReport ? 'Report' : 'Block',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
