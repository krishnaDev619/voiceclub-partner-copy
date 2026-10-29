import 'package:voiceclub_partner/core/constants/enums.dart';

class ProfileAudioModel {
  ProfileAudioStatus? profileAudioStatus;
  String? audioUrl;
  ProfileAudioType? profileAudioType;
  String? title;

  ProfileAudioModel({
    this.profileAudioStatus,
    this.profileAudioType,
    this.audioUrl,
    this.title,
  });
}
