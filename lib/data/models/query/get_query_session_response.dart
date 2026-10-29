import 'package:voiceclub_partner/data/models/query/query_session_detail.dart';

class GetQuerySessionResponse {
  final QuerySessionDetail? session;

  GetQuerySessionResponse({this.session});

  GetQuerySessionResponse.fromJson(Map<String, dynamic> json)
    : session =
          json['session'] != null
              ? QuerySessionDetail.fromJson(
                json['session'] as Map<String, dynamic>,
              )
              : null;

  Map<String, dynamic> toJson() => {'session': session?.toJson()};
}
