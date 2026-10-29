import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/data/models/chat/active_account_model.dart';
import 'package:voiceclub_partner/data/models/notifications/user_data.dart';
import 'package:voiceclub_partner/modules/controller/chat_overview_controller.dart';
import 'package:voiceclub_partner/view/widgets/custom_profile_picture.dart';

class OnlineUserCircle extends StatelessWidget {
  final ActiveAccount activeAccount;

  const OnlineUserCircle({required this.activeAccount, super.key});

  Widget _getChatDisplay(UserDataModel? user) {
    return CustomProfilePicture(
      avatarURL: user?.avatar,
      name: user?.name,
      backgroundColor: Get.theme.primaryColor,
      radius: 28,
    );
    // if (avatar?.isEmpty ?? true) {
    //   return Container(
    //     width: 64.0,
    //     height: 64.0,
    //     padding: const EdgeInsets.all(2.0),
    //     decoration: const BoxDecoration(
    //       shape: BoxShape.circle,
    //     ),
    //     child: Container(
    //       padding: const EdgeInsets.all(2.0),
    //       decoration: BoxDecoration(
    //         shape: BoxShape.circle,
    //         color: Get.theme.primaryColor,
    //       ),
    //       child: FittedBox(
    //         fit: BoxFit.scaleDown,
    //         child: Text(
    //           AvatarService.getAvatarInitials(user?.name),
    //           maxLines: 1,
    //           style: TextStyle(
    //               color: Colors.white,
    //               fontFamily: GoogleFonts.mulish().fontFamily,
    //               fontWeight: FontWeight.bold,
    //               fontSize: FontSize.xXL),
    //         ),
    //       ),
    //     ),
    //   );
    // } else {
    //   return Container(
    //     width: 64.0,
    //     height: 64.0,
    //     padding: const EdgeInsets.all(2.0),
    //     decoration: const BoxDecoration(
    //       shape: BoxShape.circle,
    //     ),
    //     child: Container(
    //       decoration: BoxDecoration(
    //         shape: BoxShape.circle,
    //         color: Get.theme.primaryColor,
    //         image: DecorationImage(
    //           image: FastCachedImageProvider(
    //             avatar ?? AvatarService.getDemandAvatarUrl(),
    //           ),
    //           fit: BoxFit.cover,
    //         ),
    //       ),
    //     ),
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final accountId = activeAccount.accountId;
        if (accountId != null) {
          if (Get.isRegistered<ChatOverviewController>()) {
            Get.find<ChatOverviewController>()
                .navigateToChatScreenUsingAccountId(
                  peerAccountId: accountId,
                  isNew: false,
                  screenName: "ActiveUsersCarousel",
                );
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8.0),
        width: 56.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 56.0,
              height: 56.0,
              child: Stack(
                children: [
                  _getChatDisplay(activeAccount.user),
                  const Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 5.0, bottom: 3.0),
                      child: CircleAvatar(
                        radius: 6.0,
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              activeAccount.user?.name ?? "Anon",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: FontSize.S),
            ),
          ],
        ),
      ),
    );
  }
}
