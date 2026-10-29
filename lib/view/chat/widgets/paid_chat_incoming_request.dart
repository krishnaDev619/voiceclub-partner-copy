import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/services/avatar_service.dart';
import 'package:voiceclub_partner/data/models/chat/chat_group.dart';
import 'package:voiceclub_partner/data/models/chat/member.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';

class PaidChatIncomingRequest extends StatefulWidget {
  final ChatGroup chatGroup;
  final String? statLabel;
  final CategoryCode categoryCode;
  final VoidCallback accept;
  final VoidCallback reject;

  const PaidChatIncomingRequest({
    super.key,
    required this.chatGroup,
    required this.categoryCode,
    required this.accept,
    required this.reject,
    required this.statLabel,
  });

  @override
  State<PaidChatIncomingRequest> createState() =>
      _PaidChatIncomingRequestState();
}

class _PaidChatIncomingRequestState extends State<PaidChatIncomingRequest> {
  ChatMember? peer;

  @override
  void initState() {
    peer =
        widget.chatGroup.members?.firstWhereOrNull(
          (member) =>
              member.accountId !=
              Get.find<UserController>().userDetails.value.accountId,
        ) ??
        ChatMember();
    super.initState();
  }

  Widget _statLabelWidget({required String? statLabel}) {
    if (statLabel?.isNotEmpty ?? false) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: ApplicationColors.primaryRed,
        ),
        child: Text(
          statLabel ?? "Paid",
          style: const TextStyle(
            fontSize: FontSize.S,
            color: Colors.white,
            fontWeight: Weight.heavy,
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(top: 8.0),
      padding: const EdgeInsets.only(bottom: 16.0, top: 12.0),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFBF1),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8.0,
            offset: Offset(0.0, -3.0),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Incoming Chat Request",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: FontSize.L,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),
          CircleAvatar(
            radius: 32.0,
            backgroundColor: Get.theme.primaryColor,
            backgroundImage: FastCachedImageProvider(
              (peer?.user?.avatar?.isNotEmpty ?? false)
                  ? peer?.user?.avatar ?? AvatarService.getRandomAvatarUrl()
                  : AvatarService.getRandomAvatarUrl(),
            ),
          ),
          Transform.translate(
            offset: const Offset(0.0, -8.0),
            child: _statLabelWidget(statLabel: widget.statLabel),
          ),
          const SizedBox(height: 8.0),
          Text(
            peer?.user?.name ?? "User",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: FontSize.xXL,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: widget.accept,
            child: Container(
              margin: const EdgeInsets.only(top: 16.0, bottom: 12.0),
              width: MediaQuery.of(context).size.width - 40.0,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 16.0,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Get.theme.primaryColor,
                border: Border.all(color: Get.theme.primaryColor),
              ),
              child: const Text(
                "Accept",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: FontSize.L,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: widget.reject,
            child: Container(
              margin: const EdgeInsets.only(top: 16.0, bottom: 12.0),
              width: MediaQuery.of(context).size.width - 40.0,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 16.0,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.transparent,
                border: Border.all(color: Get.theme.primaryColor),
              ),
              child: Text(
                "Reject",
                style: TextStyle(
                  color: Get.theme.primaryColor,
                  fontSize: FontSize.L,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
