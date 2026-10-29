import 'package:voiceclub_partner/data/models/config/icon_data.dart';

class MoreDetailsModel {
  final String? des;
  final String? subTitle;
  final String? image;
  final int? callCharge;
  final int? callBenefitPercent;
  final int? status;
  final bool? isSearch;
  final int? position;
  final IconDataModel? iconData;
  final List<String>? bannerImage;

  MoreDetailsModel({
    this.des,
    this.subTitle,
    this.image,
    this.callCharge,
    this.callBenefitPercent,
    this.status,
    this.isSearch,
    this.position,
    this.iconData,
    this.bannerImage,
  });

  MoreDetailsModel.fromJson(Map<String, dynamic> json)
    : des = json['des'] as String?,
      subTitle = json['sub_title'] as String?,
      image = json['image'] as String?,
      callCharge = json['call_charge'] as int?,
      callBenefitPercent = json['call_benefit_percent'] as int?,
      status = json['status'] as int?,
      isSearch = json['is_search'] as bool?,
      position = json['position'] as int?,
      iconData =
          (json['iconData'] as Map<String, dynamic>?) != null
              ? IconDataModel.fromJson(json['iconData'] as Map<String, dynamic>)
              : null,
      bannerImage =
          (json['banner_image'] as List?)
              ?.map((dynamic e) => e as String)
              .toList();

  Map<String, dynamic> toJson() => {
    'des': des,
    'sub_title': subTitle,
    'image': image,
    'call_charge': callCharge,
    'call_benefit_percent': callBenefitPercent,
    'status': status,
    'is_search': isSearch,
    'position': position,
    'iconData': iconData?.toJson(),
    'banner_image': bannerImage,
  };
}
