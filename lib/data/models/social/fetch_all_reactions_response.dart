import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/data/models/notifications/user_data.dart';

class GetAllPostReactionsResponseModel {
  final Map<ReactionType, List<UserDataModel>>? reactions;

  GetAllPostReactionsResponseModel({this.reactions});

  factory GetAllPostReactionsResponseModel.fromJson(Map<String, dynamic> json) {
    final reactionsMap = json['reactions'] as Map<String, dynamic>?;
    if (reactionsMap == null) return GetAllPostReactionsResponseModel();

    final Map<ReactionType, List<UserDataModel>> reactions = {};

    reactionsMap.forEach((key, value) {
      final reactionType = key.toReactionType();
      if (value != null) {
        final List<dynamic> usersList = value as List<dynamic>;
        reactions[reactionType] =
            usersList
                .map(
                  (user) =>
                      UserDataModel.fromJson(user as Map<String, dynamic>),
                )
                .toList();
      } else {
        reactions[reactionType] = [];
      }
    });

    return GetAllPostReactionsResponseModel(reactions: reactions);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> reactionsMap = {};

    reactions?.forEach((type, users) {
      reactionsMap[type.toString()] =
          users.isEmpty ? null : users.map((user) => user.toJson()).toList();
    });

    return {'reactions': reactionsMap};
  }
}
