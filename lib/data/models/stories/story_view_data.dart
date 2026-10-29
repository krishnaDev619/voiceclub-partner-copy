import 'package:voiceclub_partner/data/models/data.dart';
import 'package:voiceclub_partner/data/models/stories/story.dart';

class StoryViewDataModel {
  bool? isSeen;
  final DataModel? account;
  final StoryData? story;

  StoryViewDataModel({this.isSeen, this.account, this.story});

  StoryViewDataModel.fromJson(Map<String, dynamic> json)
    : isSeen = json['is_seen'] as bool?,
      account =
          (json['account'] as Map<String, dynamic>?) != null
              ? DataModel.fromJson(json['account'] as Map<String, dynamic>)
              : null,
      story =
          (json['story'] as Map<String, dynamic>?) != null
              ? StoryData.fromJson(json['story'] as Map<String, dynamic>)
              : null;

  Map<String, dynamic> toJson() => {
    'is_seen': isSeen,
    'account': account?.toJson(),
    'story': story?.toJson(),
  };

  void markAsSeen() {
    isSeen = true;
  }
}
