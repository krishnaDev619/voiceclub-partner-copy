import 'package:voiceclub_partner/core/constants/enums.dart';

class GetHungCallModel {
  final String? channelId;
  final String? message;
  final HungCallType? status;

  const GetHungCallModel({this.channelId, this.status, this.message});

  factory GetHungCallModel.fromJson(Map<String, dynamic> data) {
    return GetHungCallModel(
      channelId: data['channel_id'] as String?,
      message: data['message'] as String?,
      status: (data['status'] as String).toHungCallType(),
    );
  }

  Map<String, dynamic> toJson() => {
    'channel_id': channelId,
    'message': message,
    'status': status?.name,
  };
}
