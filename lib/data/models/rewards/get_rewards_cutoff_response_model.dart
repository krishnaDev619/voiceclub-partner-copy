import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/data/models/rewards/criteria.dart';

class GetRewardsCutoffResponseModel {
  final List<Criteria>? criteria;
  final num? value;
  final MetricsCutoffTag? tag;

  GetRewardsCutoffResponseModel({this.criteria, this.value, this.tag});

  GetRewardsCutoffResponseModel.fromJson(Map<String, dynamic> json)
    : criteria =
          (json['criteria'] as List?)
              ?.map((dynamic e) => Criteria.fromJson(e as Map<String, dynamic>))
              .toList(),
      value = json['value'] as num?,
      tag = (json['tag'] as String?)?.toMetricsCutoffTag();

  Map<String, dynamic> toJson() => {
    'criteria': criteria?.map((e) => e.toJson()).toList(),
    'value': value,
    'tag': tag?.name,
  };
}
