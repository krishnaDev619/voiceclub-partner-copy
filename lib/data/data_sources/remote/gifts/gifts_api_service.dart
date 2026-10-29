import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:voiceclub_partner/core/constants/api_constants.dart';
import 'package:voiceclub_partner/data/models/gifts/can_receive_gifts_response.dart';

part 'gifts_api_service.g.dart';

@RestApi()
abstract class GiftsApiService {
  factory GiftsApiService(Dio dio) = _GiftsApiService;

  @POST(APIConstants.canReceiveGiftsRoute)
  Future<HttpResponse<CanReceiveGiftsResponseModel>> canReceiveGifts({
    @Field('receiver_account_id') required int receiverAccountId,
    @Field('sender_account_id') required int senderAccountId,
  });
}
