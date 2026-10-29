import 'package:voiceclub_partner/data/models/account/audio_status.dart';

class GetAudioStatusResponseModel {
  final List<AudioStatus>? audios;

  GetAudioStatusResponseModel({this.audios});

  GetAudioStatusResponseModel.fromJson(Map<String, dynamic> json)
    : audios =
          (json['audios'] as List?)
              ?.map(
                (dynamic e) => AudioStatus.fromJson(e as Map<String, dynamic>),
              )
              .toList();

  Map<String, dynamic> toJson() => {
    'audios': audios?.map((e) => e.toJson()).toList(),
  };
}
