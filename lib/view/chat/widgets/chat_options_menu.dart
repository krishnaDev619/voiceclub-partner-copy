import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/avatar_service.dart';
import 'package:voiceclub_partner/data/models/chat/chat_group.dart';
import 'package:voiceclub_partner/data/models/chat/chat_theme.dart';
import 'package:voiceclub_partner/data/models/chat/member.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/chat/call_history/call_history_screen.dart';
import 'package:voiceclub_partner/view/notes/notes_bottom_sheet.dart';
import 'package:voiceclub_partner/view/partner_profile/widgets/block_bottom_sheet.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class ChatOptionsMenuButton extends StatefulWidget {
  final ChatGroup chatGroup;
  final ChatMember peer;
  final ChatTheme theme;
  final String? customName;
  final Map<String, dynamic> eventProperties;
  final ValueChanged<String?> onCustomNameChanged;

  const ChatOptionsMenuButton({
    super.key,
    required this.chatGroup,
    required this.peer,
    required this.theme,
    required this.customName,
    required this.eventProperties,
    required this.onCustomNameChanged,
  });

  @override
  State<ChatOptionsMenuButton> createState() => _ChatOptionsMenuButtonState();
}

class _ChatOptionsMenuButtonState extends State<ChatOptionsMenuButton> {
  final _userController = Get.find<UserController>();

  Future<void> _openNotesBottomSheet() async {
    Get.bottomSheet(
      NotesBottomSheet(
        existingNickname: widget.customName,
        userName: widget.chatGroup.title ?? "",
        accountId: widget.peer.accountId ?? 0,
        userNumber: widget.peer.user?.phoneNumber ?? "",
        screenName: "ChatScreen",
        theme: widget.theme,
        nicknameChangeCallback: widget.onCustomNameChanged,
      ),
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final peer = widget.peer;
    final theme = widget.theme;

    return PopupMenuButton(
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      elevation: 8,
      onSelected: (value) async {
        if (value == "block") {
          var isBlocked = widget.chatGroup.isBlocked ?? false;
          if (isBlocked) {
            AlertService.showSnackBar(
              snackBarType: SnackBarType.Error,
              title: LocaleKeys.liveBlocked.tr,
              subtitle: LocaleKeys.demoAlreadyBlocked.trParams({
                'name': peer.user?.name ?? '',
              }),
            );
          } else {
            sl<AnalyticsService>().trackEvent(
              'blockInitiatePartner',
              eventProperties: {
                'demandName': peer.user?.name,
                'demandUid': peer.user?.id,
              },
            );
            Get.bottomSheet(
              BlockProfileBottomSheet(
                isReport: false,
                name: peer.user?.name ?? "",
                avatar: AvatarService.getRandomAvatarUrl(),
                accountId: peer.accountId ?? 0,
              ),
              isScrollControlled: true,
              isDismissible: true,
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
            );
          }
        } else if (value == 'history') {
          Get.to(
            () => CallHistoryScreen(
              userId: peer.user?.id ?? 0,
              avatar:
                  (peer.user?.avatar?.isNotEmpty ?? false)
                      ? peer.user?.avatar ?? AvatarService.getRandomAvatarUrl()
                      : AvatarService.getRandomAvatarUrl(),
              name: peer.user?.name ?? LocaleKeys.demoAnon.tr,
              groupId: widget.chatGroup.id ?? 0,
              eventProperties: widget.eventProperties,
            ),
          );
        } else if (value == 'notes') {
          await _openNotesBottomSheet();
        }
      },
      itemBuilder: (BuildContext bc) {
        return [
          if (!_userController.currentStage.isLessThan(TutorialStage.S4))
            PopupMenuItem(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 6.0,
              ),
              height: 24.0,
              textStyle: const TextStyle(fontSize: FontSize.L),
              value: 'history',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.history, size: 20.0),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      LocaleKeys.demoCallHistory.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: FontSize.L,
                        color: Colors.black,
                        fontFamily: GoogleFonts.mulish().fontFamily,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          PopupMenuItem(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            height: 24.0,
            textStyle: const TextStyle(fontSize: FontSize.L),
            value: 'block',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.block, size: 20.0),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    LocaleKeys.demoBlockNamed.trParams({
                      'name': peer.user?.name ?? '',
                    }),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: FontSize.L,
                      color: Colors.black,
                      fontFamily: GoogleFonts.mulish().fontFamily,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!_userController.currentStage.isLessThan(TutorialStage.S5))
            PopupMenuItem(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 6.0,
              ),
              height: 24.0,
              textStyle: const TextStyle(fontSize: FontSize.L),
              value: 'notes',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.notes, size: 20.0),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      LocaleKeys.liveAddNotes.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: FontSize.L,
                        color: Colors.black,
                        fontFamily: GoogleFonts.mulish().fontFamily,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ];
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Icon(Icons.more_vert, color: theme.appBarContentColor),
      ),
    );
  }
}
