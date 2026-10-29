import 'package:flutter/services.dart';
import 'package:voiceclub_partner/core/constants/api_constants.dart';
import 'package:voiceclub_partner/core/services/logger.dart';

class RTCAppKillManager {
  static const MethodChannel _channel = MethodChannel('rtcCallEndService');

  // Call this right when the user joins/starts a call session
  static Future<void> initCallConfigs({
    required bool inCall,
    required String channelId,
    required int endedBy,
    required String jwtToken,
    required bool callAlreadyEnded,
  }) async {
    try {
      await _channel.invokeMethod('setCallConfig', {
        'inCall': inCall,
        'channel_id': channelId,
        'ended_by': endedBy,
        'jwt_token': jwtToken,
        'end_call_url':
            '${APIConstants.baseProdURL}${APIConstants.endCallRoute}',
        'call_already_ended': callAlreadyEnded,
      });
    } on PlatformException catch (e) {
      Logger.logMessage("Failed to set native call configs: ${e.message}");
    }
  }

  static Future<void> markCallAlreadyEnded() async {
    try {
      await _channel.invokeMethod('setCallAlreadyEnded');
    } on PlatformException catch (e) {
      Logger.logMessage("Failed to mark call as already ended: ${e.message}");
    }
  }
}
