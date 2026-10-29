import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:voiceclub_partner/core/constants/api_constants.dart';
import 'package:voiceclub_partner/data/models/account/get_account_preference_response.dart';
import 'package:voiceclub_partner/data/models/account/get_audio_status_response.dart';
import 'package:voiceclub_partner/data/models/account/get_criteria_users_response.dart';
import 'package:voiceclub_partner/data/models/account/get_current_online_duration_response.dart';
import 'package:voiceclub_partner/data/models/account/get_kyc_response.dart';
import 'package:voiceclub_partner/data/models/account/get_meeting_schedule_response.dart';
import 'package:voiceclub_partner/data/models/account/get_reverse_calls_reseponse.dart';
import 'package:voiceclub_partner/data/models/account/onboarding_details.dart';
import 'package:voiceclub_partner/data/models/account/rewards_stats.dart';
import 'package:voiceclub_partner/data/models/base_response.dart';
import 'package:voiceclub_partner/data/models/data.dart';
import 'package:voiceclub_partner/data/models/file/upload_file_response.dart';

part 'account_api_service.g.dart';

@RestApi()
abstract class AccountApiService {
  factory AccountApiService(Dio dio) = _AccountApiService;

  @GET(APIConstants.getSupplyProfileRoute)
  Future<HttpResponse<DataModel>> getSupplyProfile();

  @POST(APIConstants.updateStatusRoute)
  Future<HttpResponse> updateStatus(@Field('is_online') bool isOnline);

  @POST(APIConstants.updateRecordingRoute)
  Future<HttpResponse> updateRecording({
    @Field('recording_url') required String url,
    @Field('type') required String type,
    @Field('language') required String language,
    @Field('status') required String status,
    @Field('reason') String? reason,
  });

  @GET(APIConstants.getAccountPreferenceRoute)
  Future<HttpResponse<GetAccountPreferenceResponseModel>>
  getAccountPreference();

  @GET(APIConstants.getCurrentOnlineDurationRoute)
  Future<HttpResponse<GetCurrentOnlineDurationResponseModel>>
  getCurrentOnlineDuration();

  @POST(APIConstants.updateAccountPreferenceRoute)
  Future<HttpResponse<void>> updateAccountPreference({
    @Field('call_preference') required String callPreference,
    @Field('chat_preference') required String chatPreference,
  });

  @GET(APIConstants.getAudioStatusRoute)
  Future<HttpResponse<GetAudioStatusResponseModel>> getAudioStatus();

  @GET(APIConstants.getCriteriaUserRoute)
  Future<HttpResponse<GetCriteriaUsersResponseModel>> getCriteriaUsers({
    @Path("cutoffFlag") required int cutoffFlag,
    @Query('query') String? searchQuery,
    @Query('page') required int page,
    @Query('page_size') required int pageSize,
  });

  @POST(APIConstants.updateLanguageRoute)
  Future<HttpResponse> updateLanguage({
    @Field('first_language') required String firstLanguage,
    @Field('second_language') required String secondLanguage,
  });

  @POST(APIConstants.updateNotificationPreferenceRoute)
  Future<HttpResponse> updateNotificationPreference({
    @Path('preference') required String notificationPreference,
  });

  @POST(APIConstants.updateKYCRoute)
  Future<HttpResponse> updateKYC({
    @Field('name') required String name,
    @Field('pan_image_path') required String panImagePath,
    @Field('selfie_image_path') required String selfieImagePath,
    @Field('pan_number') required String panNumber,
    @Field('ifsc') required String ifsc,
    @Field('account_number') required String accountNumber,
    @Field('kyc_verified') required bool isVerified,
  });

  @GET(APIConstants.getKYCRoute)
  Future<HttpResponse<GetKYCResponseModel>> getKYC();

  @POST(APIConstants.updateLocationRoute)
  Future<HttpResponse> updateLocation({
    @Field('city') required String city,
    @Field('state') required String state,
  });

  @GET(APIConstants.getReverseCallsRoute)
  Future<HttpResponse<GetReverseCallsResponse>> getReverseCalls({
    @Query('page') required int page,
    @Query('page_size') required int pageSize,
  });

  @POST(APIConstants.updateOnboardingStageRoute)
  Future<HttpResponse> updateOnboardingStage({
    @Field('stage') required String stage,
    @Field('date') required String date,
  });

  @POST(APIConstants.markOnboardingStageCourseCompletedRoute)
  Future<HttpResponse> markOnboardingStageCourseCompleted();

  @PUT(APIConstants.updateSupplyProfileRoute)
  Future<HttpResponse> updateSupplyProfile({
    @Field('name') required String name,
    @Field('image') required String avatarUrl,
  });

  @GET(APIConstants.getOnboardingSelfieRoute)
  Future<HttpResponse<FileResponseModel>> getOnboardingSelfie();

  @GET(APIConstants.getMeetingScheduleRoute)
  Future<HttpResponse<GetMeetingScheduleResponseModel>> getMeetingSchedule({
    @Query('page') required int page,
    @Query('page_size') required int pageSize,
  });

  @POST(APIConstants.markOnboardingCompletedRoute)
  Future<HttpResponse<void>> markOnboardingCompleted();

  @GET(APIConstants.getRewardsStatsRoute)
  Future<HttpResponse<RewardsStatsResponse>> getRewardsStats();

  @POST(APIConstants.updateESignRoute)
  Future<HttpResponse<BaseResponseModel>> updateESign({
    @Field('transaction_id') required String transactionId,
    @Field('signed_document_path') required String signedDocumentPath,
    @Field('masked_aadhar') required String maskedAadhar,
    @Field('name') required String name,
    @Field('ifsc') required String ifsc,
    @Field('account_number') required String accountNumber,
    @Field('type') required String type,
    @Field('upi') required String upi,
  });

  @GET(APIConstants.onboardingDetailsRoute)
  Future<HttpResponse<OnboardingDetailsResponseModel>> getOnboardingDetails();
}
