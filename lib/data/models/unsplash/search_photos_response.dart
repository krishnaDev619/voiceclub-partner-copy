import 'package:voiceclub_partner/data/models/unsplash/unsplash_photo.dart';

class SearchPhotosResponseModel {
  final int? total;
  final int? totalPages;
  final List<UnsplashPhoto>? results;

  SearchPhotosResponseModel({this.total, this.totalPages, this.results});

  factory SearchPhotosResponseModel.fromJson(Map<String, dynamic> json) {
    return SearchPhotosResponseModel(
      total: json['total'] as int?,
      totalPages: json['total_pages'] as int?,
      results:
          (json['results'] as List<dynamic>?)
              ?.map((e) => UnsplashPhoto.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'total_pages': totalPages,
      'results': results?.map((e) => e.toJson()).toList(),
    };
  }
}
