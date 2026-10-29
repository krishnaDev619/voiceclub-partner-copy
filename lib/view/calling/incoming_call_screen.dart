import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/domain/usecases/calling/set_ring.dart'
    as ring;
import 'package:voiceclub_partner/modules/controller/call_controller.dart';
import 'package:voiceclub_partner/modules/controller/calls/incoming_call_controller.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/calling/widgets/answer_call_widget.dart';
import 'package:voiceclub_partner/view/calling/widgets/call_info_button.dart';
import 'package:voiceclub_partner/view/calling/widgets/call_notes_button.dart';
import 'package:voiceclub_partner/view/calling/widgets/call_stat_label_widget.dart';
import 'package:voiceclub_partner/view/calling/widgets/call_timer_widget.dart';
import 'package:voiceclub_partner/view/calling/widgets/call_user_details_widget.dart';
import 'package:voiceclub_partner/view/calling/widgets/incoming_call_functions_widget.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/core/disabled_widget.dart';

class IncomingCallScreen extends StatefulWidget {
  final bool setRing;
  final String channelId;

  const IncomingCallScreen({
    super.key,
    required this.setRing,
    required this.channelId,
  });

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenGossipState();
}

class _IncomingCallScreenGossipState extends State<IncomingCallScreen> {
  final incomingCallController = Get.find<IncomingCallController>();

  @override
  void initState() {
    _setRinging();
    AwesomeNotifications().cancelNotificationsByChannelKey("1");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleInvalidCallState();
    });
    super.initState();
  }

  Future<void> _setRinging() async {
    if (widget.setRing) {
      Logger.logMessage(
        "Set Ring called",
        name: "IncomingCallController",
        isCritical: true,
      );
      final result = await sl<ring.SetRingUsecase>().call(
        ring.Params(channelId: widget.channelId),
      );
      if (result.error == null) {
        incomingCallController.startRingingTimer();
      }
    }
  }

  void _handleInvalidCallState() {
    try {
      if (sl<CallController>().handleInvalidCallState.value &&
          sl<CallController>().incomingCallPayload.value == widget.channelId) {
        Logger.logMessage(
          'Call state stream state is invalid ${widget.channelId}...Ending call',
          name: 'IncomingCallController',
        );
        sl<CallController>().setHandleInvalidCallState(false);
        incomingCallController.leave();
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    incomingCallController.dispose();
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
          body: Stack(
            fit: StackFit.expand,
            children: [
              Visibility(
                visible: incomingCallController.isNewUser,
                child: SizedBox(
                  height: Get.height,
                  width: Get.width,
                  child: Image.asset(
                    AssetConstants.firstCallBg,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Disabled(
                      disabled: Get.find<UserController>().currentStage
                          .isLessThan(TutorialStage.S5),
                      child: CallNotesButton(
                        isCallAccepted: incomingCallController.isAccepted.value,
                        demandName: incomingCallController.name,
                        demandAccountId:
                            incomingCallController.demandAccountId.value,
                        openNotesFunction:
                            incomingCallController.openNotesBottomSheet,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    CallUserDetailsWidget(
                      name: incomingCallController.name,
                      avatar: incomingCallController.avatar,
                      customName:
                          incomingCallController.callModel.value?.customName,
                      isNewUser: incomingCallController.isNewUser,
                    ),
                    CallTimerWidget(
                      isAccepted: incomingCallController.isAccepted.value,
                      callDurationSeconds:
                          incomingCallController.callDurationSeconds.value,
                      callModel: incomingCallController.callModel.value,
                      remoteUserMute:
                          incomingCallController.remoteUserMute.value,
                      isNewUser: incomingCallController.isNewUser,
                    ),
                    const SizedBox(height: 10.0),
                    CallStatLabelWidget(
                      callStatLabel:
                          incomingCallController.callModel.value?.callStatLabel,
                      demandLanguage:
                          incomingCallController
                              .callModel
                              .value
                              ?.demandLanguage,
                      isNewUser: incomingCallController.isNewUser,
                    ),
                    const SizedBox(height: 10.0),
                    CallInfoButton(
                      isAccepted: incomingCallController.isAccepted.value,
                      demandName: incomingCallController.name,
                      channelId: incomingCallController.channelId,
                      callStatLabel:
                          incomingCallController
                              .callModel
                              .value
                              ?.callStatLabel ??
                          "Old User",
                    ),
                    const Expanded(child: SizedBox()),
                    Visibility(
                      visible: incomingCallController.isAccepted.value,
                      replacement: AnswerCallWidget(
                        isNew: incomingCallController.isNew.value,
                        onAccept: incomingCallController.join,
                        onReject: () {
                          incomingCallController.leave(isMe: true);
                        },
                        rejectedCallCount:
                            incomingCallController
                                .callModel
                                .value
                                ?.rejectedCallCount,
                        isLifeTimeCallBannerActive:
                            incomingCallController.isNewUser,
                      ),
                      child: const IncomingCallFunctionsWidget(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
