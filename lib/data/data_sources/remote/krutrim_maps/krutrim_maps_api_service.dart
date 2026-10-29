import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:voiceclub_partner/core/constants/api_constants.dart';
import 'package:voiceclub_partner/data/models/krutrim_maps/address_model.dart';

part 'krutrim_maps_api_service.g.dart';

@RestApi()
abstract class KrutrimMapsApiService {
  factory KrutrimMapsApiService(Dio dio) = _KrutrimMapsApiService;

  @POST(APIConstants.krutrimMapsReverseGeocodingRoute)
  Future<HttpResponse<KrutrimMapsReverseGeocodingResponseModel>> getAddress({
    @Field('latitude') required String latitude,
    @Field('longitude') required String longitude,
  });
}
