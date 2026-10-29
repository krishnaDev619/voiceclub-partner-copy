import 'package:voiceclub_partner/data/models/spotlight/stories.dart';

class StoryWrapper {
  final Stories? story;

  StoryWrapper(this.story);

  StoryWrapper.fromJson(Map<String, dynamic> json)
    : story = json['story'] != null ? Stories.fromJson(json['story']) : null;
}
