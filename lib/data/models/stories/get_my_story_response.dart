import 'package:voiceclub_partner/data/models/stories/story_view_data.dart';

class GetMyStoryResponseModel {
  final bool? hasStory;
  final StoryViewDataModel? storyData;
  final int? viewCount;

  GetMyStoryResponseModel({this.hasStory, this.storyData, this.viewCount});

  GetMyStoryResponseModel.fromJson(Map<String, dynamic> json)
    : hasStory = json['has_story'] as bool?,
      storyData =
          (json['story_data'] as Map<String, dynamic>?) != null
              ? StoryViewDataModel.fromJson(
                json['story_data'] as Map<String, dynamic>,
              )
              : null,
      viewCount = json['view_count'] as int?;

  Map<String, dynamic> toJson() => {
    'has_story': hasStory,
    'story_data': storyData?.toJson(),
    'view_count': viewCount,
  };
}
