import 'package:voiceclub_partner/data/models/notifications/user_data.dart';

class GetAllReactionsResponse {
  final List<UserDataModel>? users;

  GetAllReactionsResponse({this.users});

  GetAllReactionsResponse.fromJson(Map<String, dynamic> json)
    : users =
          (json['users'] as List?)
              ?.map(
                (dynamic e) =>
                    UserDataModel.fromJson(e as Map<String, dynamic>),
              )
              .toList();

  Map<String, dynamic> toJson() => {
    'users': users?.map((e) => e.toJson()).toList(),
  };
}
