import 'package:voiceclub_partner/core/constants/enums.dart';

class AudioStatus {
  final int? id;
  final RecordingAudioStatus? status;
  final RecordingAudioType? type;
  final String? audioUrl;
  final String? reason;

  AudioStatus({this.id, this.status, this.type, this.audioUrl, this.reason});

  AudioStatus.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int?,
      status = (json['status'] as String? ?? "").toRecordingAudioStatus(),
      type = (json['type'] as String? ?? "").toRecordingAudioType(),
      audioUrl = json['audio_url'] as String?,
      reason = json['reason'] as String?;

  Map<String, dynamic> toJson() => {
    'id': id,
    'status': status?.name,
    'type': type?.name,
    'audio_url': audioUrl,
    'reason': reason,
  };
}
