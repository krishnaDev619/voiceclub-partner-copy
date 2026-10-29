import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/calling/widgets/call_language_widget.dart';
import 'package:voiceclub_partner/view/calling/widgets/call_user_stat_widget.dart';

final GlobalKey<PopupMenuButtonState> userInfoPopupMenuKey =
    GlobalKey<PopupMenuButtonState>();
bool isUserInfoPopupMenuOpen = false;

void closeUserInfoPopupMenuIfOpen() {
  if (isUserInfoPopupMenuOpen) {
    Get.back(closeOverlays: true);
  }
}

class CallStatLabelWidget extends StatefulWidget {
  const CallStatLabelWidget({
    super.key,
    required this.callStatLabel,
    required this.demandLanguage,
    required this.isNewUser,
  });
  final String? callStatLabel;
  final String? demandLanguage;
  final bool isNewUser;

  @override
  State<CallStatLabelWidget> createState() => _CallStatLabelWidgetState();
}

class _CallStatLabelWidgetState extends State<CallStatLabelWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      try {
        //Auto show user info popup menu for new users when partner is in probation
        if (widget.isNewUser &&
            Get.find<UserController>().partnerStatus.value ==
                PartnerCurrentStatus.PROBATION) {
          isUserInfoPopupMenuOpen = true;
          userInfoPopupMenuKey.currentState?.showButtonMenu();
        }
      } catch (e) {
        Logger.logMessage(
          'Error showing user info popup menu error: $e',
          name: 'CallStatLabelWidget',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Visibility(
          visible: widget.callStatLabel?.isNotEmpty ?? false,
          child: PopupMenuButton(
            key: userInfoPopupMenuKey,
            tooltip: '',
            color: Colors.transparent,
            shadowColor: Colors.transparent,
            offset: Offset(-60, 35),

            itemBuilder:
                (context) => [PopupMenuItem(child: CallUserStatWidget())],
            onOpened: () {
              isUserInfoPopupMenuOpen = true;
            },
            onCanceled: () {
              isUserInfoPopupMenuOpen = false;
            },
            onSelected: (_) {
              isUserInfoPopupMenuOpen = false;
            },

            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color:
                    widget.isNewUser
                        ? const Color(0xFF948BB1)
                        : const Color(0xFFFFE6CF),
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 16.0,
                        color: widget.isNewUser ? Colors.white : Colors.black54,
                      ),
                      SizedBox(width: 3),
                    ],
                  ),
                  Text(
                    widget.callStatLabel ?? "",
                    style: TextStyle(
                      color: widget.isNewUser ? Colors.white : Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 20.0),
        CallLanguageWidget(
          demandLanguage: widget.demandLanguage,
          isNewUser: widget.isNewUser,
        ),
      ],
    );
  }
}
