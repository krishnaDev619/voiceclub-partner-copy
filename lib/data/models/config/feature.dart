import 'package:voiceclub_partner/core/constants/enums.dart';

class Feature {
  final ChatType? name;
  final int? limit;

  Feature({this.name, this.limit});

  Feature.fromJson(Map<String, dynamic> json)
    : name = (json['name'] as String? ?? '').toChatType(),
      limit = json['limit'] as int?;

  Map<String, dynamic> toJson() => {'name': name, 'limit': limit};
}
