import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/data/models/chat/member.dart';
import 'package:voiceclub_partner/domain/usecases/chat/report_chat_message.dart';

class ReportMessageBottomSheet extends StatefulWidget {
  const ReportMessageBottomSheet({
    super.key,
    required this.content,
    required this.chatGroupId,
    required this.documentId,
    required this.peerData,
  });
  final String content, documentId;
  final int chatGroupId;
  final ChatMember peerData;

  @override
  State<ReportMessageBottomSheet> createState() =>
      _ReportMessageBottomSheetState();
}

class _ReportMessageBottomSheetState extends State<ReportMessageBottomSheet> {
  BlockReason selectedReason = BlockReason.Offensive;
  OtherReason selectedOtherReason = OtherReason.personal;

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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
                const Icon(
                  Icons.report_problem_rounded,
                  color: Colors.red,
                  size: 54.0,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    'Reason for reporting?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                    ),
                  ),
                ),
                RadioGroup(
                  onChanged: (newReason) {
                    setState(() {
                      selectedReason = newReason ?? selectedReason;
                    });
                  },
                  groupValue: selectedReason,
                  child: Row(
                    children: [
                      for (final reason in BlockReason.values)
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Radio(
                                key: Key(reason.hashCode.toString()),
                                activeColor: Get.theme.primaryColor,
                                visualDensity: const VisualDensity(
                                  horizontal: VisualDensity.minimumDensity,
                                  vertical: VisualDensity.minimumDensity,
                                ),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                value: reason,
                              ),
                              const SizedBox(width: 2.0),
                              Text(
                                reason.name,
                                maxLines: 1,
                                overflow: TextOverflow.clip,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                selectedReason == BlockReason.Other
                    ? Column(
                      children: [
                        const SizedBox(height: 12.0),
                        for (final other in otherReasons.entries)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedOtherReason = other.key;
                              });
                            },
                            child: Opacity(
                              opacity:
                                  other.key == selectedOtherReason ? 1.0 : 0.3,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(8.0),
                                margin: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(8.0),
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
                                      style: const TextStyle(fontSize: 12.0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                    : const SizedBox.shrink(),
              ],
            ), // Show check icon
          ),
          const SizedBox(height: 12.0),
          GestureDetector(
            onTap: () async {
              HapticFeedback.vibrate();
              String reason = getReason();
              await sl<ReportChatMessageUsecase>().call(
                Params(
                  chatGroupId: widget.chatGroupId,
                  documentId: widget.documentId,
                  reason: reason,
                ),
              );
              sl<AnalyticsService>().trackEvent(
                "reportMessagePartner",
                eventProperties: {
                  "content": widget.content,
                  "reason": reason,
                  "groupId": widget.chatGroupId,
                  "demandName": widget.peerData.user?.name,
                  "demandNumber": widget.peerData.user?.phoneNumber,
                  "demandUid": widget.peerData.user?.id,
                },
              );
              Get.back();
            },
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Get.theme.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Report',
                      style: TextStyle(
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
