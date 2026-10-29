import 'package:voiceclub_partner/data/models/wallet/overview_data.dart';

class GetOverviewResponseModel {
  final OverviewDataModel? overviewData;

  GetOverviewResponseModel({this.overviewData});

  GetOverviewResponseModel.fromJson(Map<String, dynamic> json)
    : overviewData =
          (json['overview_data'] as Map<String, dynamic>?) != null
              ? OverviewDataModel.fromJson(
                json['overview_data'] as Map<String, dynamic>,
              )
              : null;

  Map<String, dynamic> toJson() => {'overview_data': overviewData?.toJson()};
}
