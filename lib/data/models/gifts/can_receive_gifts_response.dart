class CanReceiveGiftsResponseModel {
  final bool? enabled;

  CanReceiveGiftsResponseModel({this.enabled});

  CanReceiveGiftsResponseModel.fromJson(Map<String, dynamic> json)
    : enabled = json['enabled'] as bool?;

  Map<String, dynamic> toJson() => {'enabled': enabled};
}
