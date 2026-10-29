import 'package:voiceclub_partner/data/models/rating/rating_model.dart';

class GetAllRatingsResponseModel {
  final List<RatingModel>? ratings;
  final int? page;
  final int? totalItems;
  final int? totalPages;

  GetAllRatingsResponseModel({
    this.ratings,
    this.page,
    this.totalItems,
    this.totalPages,
  });

  GetAllRatingsResponseModel.fromJson(Map<String, dynamic> json)
    : ratings =
          (json['ratings'] as List?)
              ?.map(
                (dynamic e) => RatingModel.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      page = json['page'] as int?,
      totalItems = json['total_items'] as int?,
      totalPages = json['total_pages'] as int?;

  Map<String, dynamic> toJson() => {
    'ratings': ratings?.map((e) => e.toJson()).toList(),
    'page': page,
    'total_items': totalItems,
    'total_pages': totalPages,
  };
}
