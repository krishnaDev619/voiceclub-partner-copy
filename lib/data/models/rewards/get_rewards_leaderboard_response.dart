import 'package:voiceclub_partner/data/models/rewards/my_rank.dart';
import 'package:voiceclub_partner/data/models/rewards/ranks.dart';

class GetRewardsLeaderboardResponseModel {
  final List<Ranks>? ranks;
  final MyRank? myRank;
  final int? page;
  final int? totalItems;
  final int? totalPages;
  final String? lastUpdatedTime;

  GetRewardsLeaderboardResponseModel({
    this.ranks,
    this.myRank,
    this.page,
    this.totalItems,
    this.totalPages,
    this.lastUpdatedTime,
  });

  GetRewardsLeaderboardResponseModel.fromJson(Map<String, dynamic> json)
    : ranks =
          (json['ranks'] as List?)
              ?.map((dynamic e) => Ranks.fromJson(e as Map<String, dynamic>))
              .toList(),
      myRank =
          (json['my_rank'] as Map<String, dynamic>?) != null
              ? MyRank.fromJson(json['my_rank'] as Map<String, dynamic>)
              : null,
      page = json['page'] as int?,
      totalItems = json['total_items'] as int?,
      totalPages = json['total_pages'] as int?,
      lastUpdatedTime = json['last_updated_time'] as String?;

  Map<String, dynamic> toJson() => {
    'ranks': ranks?.map((e) => e.toJson()).toList(),
    'my_rank': myRank?.toJson(),
    'page': page,
    'total_items': totalItems,
    'total_pages': totalPages,
    'last_updated_time': lastUpdatedTime,
  };
}
