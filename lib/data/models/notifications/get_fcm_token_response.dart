import 'package:voiceclub_partner/data/models/notifications/user_data.dart';

class GetFCMResponseModel {
  final UserDataModel? user;

  GetFCMResponseModel({this.user});

  GetFCMResponseModel.fromJson(Map<String, dynamic> json)
    : user =
          (json['user'] as Map<String, dynamic>?) != null
              ? UserDataModel.fromJson(json['user'] as Map<String, dynamic>)
              : null;

  Map<String, dynamic> toJson() => {'user': user?.toJson()};
}
