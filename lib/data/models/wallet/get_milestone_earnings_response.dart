class GetMilestoneEarningsResponseModel {
  final num? lifetime;
  final num? yearly;

  GetMilestoneEarningsResponseModel({this.lifetime, this.yearly});

  GetMilestoneEarningsResponseModel.fromJson(Map<String, dynamic> json)
    : lifetime = json['lifetime'] as num?,
      yearly = json['yearly'] as num?;

  Map<String, dynamic> toJson() => {'lifetime': lifetime, 'yearly': yearly};
}
