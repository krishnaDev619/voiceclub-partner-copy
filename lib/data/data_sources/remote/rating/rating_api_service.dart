import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:voiceclub_partner/core/constants/api_constants.dart';
import 'package:voiceclub_partner/data/models/rating/get_all_ratings_response.dart';

part 'rating_api_service.g.dart';

@RestApi()
abstract class RatingApiService {
  factory RatingApiService(Dio dio) = _RatingApiService;

  @POST(APIConstants.addRatingRoute)
  Future<HttpResponse> addRating(
    @Field('rated_account_id') int accountId,
    @Field('rating') int rating,
  );

  @GET(APIConstants.getAllRatingsRoute)
  Future<HttpResponse<GetAllRatingsResponseModel>> getAllRatings();
}
