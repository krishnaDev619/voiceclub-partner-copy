class OverviewDataModel {
  final num? totalAmount;
  final int? totalCalls;
  final int? totalSecond;

  OverviewDataModel({this.totalAmount, this.totalCalls, this.totalSecond});

  OverviewDataModel.fromJson(Map<String, dynamic> json)
    : totalAmount = json['total_amount'] as num?,
      totalCalls = json['total_calls'] as int?,
      totalSecond = json['total_second'] as int?;

  Map<String, dynamic> toJson() => {
    'total_amount': totalAmount,
    'total_calls': totalCalls,
    'total_second': totalSecond,
  };
}
