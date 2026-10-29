import 'package:voiceclub_partner/data/models/chat/chat_filter.dart';

class GetChatFilterOptionsResponseModel {
  final List<ChatFilter>? filters;

  GetChatFilterOptionsResponseModel({this.filters});

  GetChatFilterOptionsResponseModel.fromJson(Map<String, dynamic> json)
    : filters =
          (json['filters'] as List?)
              ?.map(
                (dynamic e) => ChatFilter.fromJson(e as Map<String, dynamic>),
              )
              .toList();

  Map<String, dynamic> toJson() => {
    'filters': filters?.map((e) => e.toJson()).toList(),
  };
}
