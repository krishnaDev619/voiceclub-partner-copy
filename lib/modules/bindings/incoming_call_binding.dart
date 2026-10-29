import 'dart:async';

import 'package:get/get.dart';
import 'package:voiceclub_partner/data/models/calling/call_model.dart';
import 'package:voiceclub_partner/data/models/calling/call_state_model.dart';
import 'package:voiceclub_partner/modules/controller/calls/incoming_call_controller.dart';

class IncomingCallBinding extends Bindings {
  final String channelId;
  final CallModel initCallData;
  final int callerUid;
  final String name;
  final String? avatar;
  final StreamSubscription<CallStateModel?> callStateStreamSubscription;
  final num lifeTimeCallDuration;

  IncomingCallBinding({
    required this.channelId,
    required this.name,
    required this.callerUid,
    required this.avatar,
    required this.initCallData,
    required this.callStateStreamSubscription,
    required this.lifeTimeCallDuration,
  });

  @override
  void dependencies() {
    Get.lazyPut(
      () => IncomingCallController(
        channelId: channelId,
        callerUid: callerUid,
        name: name,
        avatar: avatar,
        initCallData: initCallData,
        callStateStreamSubscription: callStateStreamSubscription,
        lifeTimeCallDuration: lifeTimeCallDuration,
      ),
    );
  }
}
