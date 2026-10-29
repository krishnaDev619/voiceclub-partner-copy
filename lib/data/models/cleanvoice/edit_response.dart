import 'package:voiceclub_partner/core/constants/enums.dart';

class CleanVoiceEditResponseModel {
  final EditStatus status;
  final CleanVoiceEditResult? result;
  final String taskId;

  CleanVoiceEditResponseModel({
    required this.status,
    this.result,
    required this.taskId,
  });

  CleanVoiceEditResponseModel.fromJson(Map<String, dynamic> json)
    : status = (json['status'] as String).toEditStatus(),
      result =
          json['result'] != null
              ? CleanVoiceEditResult.fromJson(
                json['result'] as Map<String, dynamic>,
              )
              : null,
      taskId = json['task_id'] as String;

  Map<String, dynamic> toJson() => {
    'status': status,
    'result': result?.toJson(),
    'task_id': taskId,
  };
}

class CleanVoiceEditResult {
  final String filename;
  final String? downloadUrl;

  CleanVoiceEditResult({required this.filename, this.downloadUrl});

  CleanVoiceEditResult.fromJson(Map<String, dynamic> json)
    : filename = json['filename'] as String,
      downloadUrl = json['download_url'] as String?;

  Map<String, dynamic> toJson() => {
    'filename': filename,
    'download_url': downloadUrl,
  };
}
