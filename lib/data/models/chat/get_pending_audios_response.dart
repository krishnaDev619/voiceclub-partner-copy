import 'package:voiceclub_partner/data/models/chat/pending_audio.dart';

class GetPendingAudiosResponseModel {
  final List<PendingAudio>? audios;
  final int? page;
  final int? totalItems;
  final int? totalPages;

  GetPendingAudiosResponseModel({
    this.audios,
    this.page,
    this.totalItems,
    this.totalPages,
  });

  GetPendingAudiosResponseModel.fromJson(Map<String, dynamic> json)
    : audios =
          (json['audios'] as List?)
              ?.map(
                (dynamic e) => PendingAudio.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      page = json['page'] as int?,
      totalItems = json['total_items'] as int?,
      totalPages = json['total_pages'] as int?;

  Map<String, dynamic> toJson() => {
    'audios': audios?.map((e) => e.toJson()).toList(),
    'page': page,
    'total_items': totalItems,
    'total_pages': totalPages,
  };
}
