class RatingModel {
  final int? accountId;
  final int? rating;
  final String? message;

  RatingModel({this.accountId, this.rating, this.message});

  RatingModel.fromJson(Map<String, dynamic> json)
    : accountId = json['account_id'] as int?,
      rating = json['rating'] as int?,
      message = json['message'] as String?;

  Map<String, dynamic> toJson() => {
    'account_id': accountId,
    'rating': rating,
    'message': message,
  };
}
