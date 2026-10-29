import 'package:voiceclub_partner/data/models/more_details.dart';

class GetMoreModel {
  final List<String>? bannerList;
  final List<MoreDetailsModel>? moreDetails;

  GetMoreModel({this.bannerList, this.moreDetails});

  GetMoreModel.fromJson(Map<String, dynamic> json)
    : bannerList =
          (json['banner_list'] as List?)
              ?.map((dynamic e) => e as String)
              .toList(),
      moreDetails =
          (json['more_details'] as List?)
              ?.map(
                (dynamic e) =>
                    MoreDetailsModel.fromJson(e as Map<String, dynamic>),
              )
              .toList();

  Map<String, dynamic> toJson() => {
    'banner_list': bannerList,
    'more_details': moreDetails?.map((e) => e.toJson()).toList(),
  };
}
