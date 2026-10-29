import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:voiceclub_partner/core/constants/api_constants.dart';

part 'notifications_api_service.g.dart';

@RestApi()
abstract class NotificationsApiService {
  factory NotificationsApiService(Dio dio) = _NotificationsApiService;

  @POST(APIConstants.addNotificationRoute)
  Future<HttpResponse> addNotification({
    @Field('uid') required int uid,
    @Field('is_audio') required bool isAudio,
    @Field('audio_url') required String audioUrl,
  });

  @POST(APIConstants.testNotificationRoute)
  Future<HttpResponse> testNotification();
}
