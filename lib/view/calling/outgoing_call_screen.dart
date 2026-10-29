import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/modules/controller/calls/outgoing_call_controller.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/calling/widgets/call_language_widget.dart';
import 'package:voiceclub_partner/view/calling/widgets/call_notes_button.dart';
import 'package:voiceclub_partner/view/calling/widgets/call_user_details_widget.dart';
import 'package:voiceclub_partner/view/calling/widgets/outgoing_call_functions_widget.dart';
import 'package:voiceclub_partner/view/calling/widgets/outgoing_call_timer_widget.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/core/disabled_widget.dart';

class OutgoingCallScreen extends StatefulWidget {
  final String channelId;
  final String token;
  final int demandUid;
  final int demandAccountId;
  final String demandName;
  final String demandPhoneNumber;
  final String? demandAvatar;
  final String screenName;
  final int? chatGroupId;

  const OutgoingCallScreen({
    super.key,
    required this.channelId,
    required this.token,
    required this.demandUid,
    required this.demandAccountId,
    required this.demandName,
    required this.demandPhoneNumber,
    required this.demandAvatar,
    required this.screenName,
    this.chatGroupId,
  });

  @override
  State<OutgoingCallScreen> createState() => _OutgoingCallScreenState();
}

class _OutgoingCallScreenState extends State<OutgoingCallScreen> {
  late OutgoingCallController outgoingCallController;

  @override
  void initState() {
    outgoingCallController = Get.put(
      OutgoingCallController(
        demandUid: widget.demandUid,
        demandAccountId: widget.demandAccountId,
        name: widget.demandName,
        phoneNo: widget.demandPhoneNumber,
        avatar: widget.demandAvatar,
        channelId: widget.channelId,
        token: widget.token,
        screenName: widget.screenName,
        chatGroupId: widget.chatGroupId,
      ),
    );

    super.initState();
  }

  @override
  void dispose() {
    outgoingCallController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: const Color(0xFFFFF3E8),
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(0.0),
            child: AppBar(
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: Color(0xFFFFF3E8),
                statusBarIconBrightness: Brightness.dark,
              ),
              backgroundColor: const Color(0xFFFFF3E8),
              elevation: 0.0,
            ),
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Disabled(
                  disabled: Get.find<UserController>().currentStage.isLessThan(
                    TutorialStage.S5,
                  ),
                  child: CallNotesButton(
                    isCallAccepted: outgoingCallController.isAccepted.value,
                    demandName: widget.demandName,
                    demandAccountId: outgoingCallController.demandAccountId,
                    openNotesFunction:
                        outgoingCallController.openNotesBottomSheet,
                  ),
                ),
                const SizedBox(height: 12.0),
                CallUserDetailsWidget(
                  name: widget.demandName,
                  avatar: widget.demandAvatar,
                  customName:
                      outgoingCallController.callModel.value?.customName,
                ),
                const SizedBox(height: 10),
                OutgoingCallTimerWidget(
                  isAccepted: outgoingCallController.isAccepted.value,
                  ringState:
                      outgoingCallController.callStateModel.value?.ringState,
                  callOnlySeconds: outgoingCallController.callOnlySeconds.value,
                  countDownSeconds:
                      outgoingCallController.countDownSeconds.value,
                  remoteUserMute: outgoingCallController.remoteUserMute.value,
                ),
                const SizedBox(height: 20.0),
                CallLanguageWidget(
                  demandLanguage:
                      outgoingCallController.callModel.value?.demandLanguage,
                  isNewUser: false,
                ),
                const Spacer(),
                const OutgoingCallFunctionsWidget(),
              ],
            ),
          ),
        ),
      );
    });
  }
}
