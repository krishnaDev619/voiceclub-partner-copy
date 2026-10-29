import 'package:voiceclub_partner/core/resources/data_state.dart';
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

abstract class AccountRepository {
  Future<DataState<DataModel>> getSupplyProfile();

  Future<DataState<void>> updateStatus(bool isOnline);

  Future<DataState<void>> updateRecording({
    required String url,
    required String type,
    required String language,
    required String status,
    String? reason,
  });

  Future<DataState<GetAccountPreferenceResponseModel>> getAccountPreference();

  Future<DataState<void>> updateAccountPreference({
    required String callPreference,
    required String chatPreference,
  });

  Future<DataState<GetAudioStatusResponseModel>> getAudioStatus();

  Future<DataState<GetCurrentOnlineDurationResponseModel>>
  getCurrentOnlineDuration();

  Future<DataState<GetCriteriaUsersResponseModel>> getCriteriaUsers({
    required int cutoffFlag,
    String? searchQuery,
    required int page,
    required int pageSize,
  });

  Future<DataState<void>> updateLanguage({
    required String firstLanguage,
    required String secondLanguage,
  });

  Future<DataState<void>> updateNotificationPreference({
    required String notificationPreference,
  });

  Future<DataState<void>> updateKYC({
    required String name,
    required String panImagePath,
    required String selfieImagePath,
    required String panNumber,
    required String ifsc,
    required String accountNumber,
    required bool isVerified,
  });

  Future<DataState<GetKYCResponseModel>> getKYC();

  Future<DataState> updateLocation({
    required String city,
    required String state,
  });

  Future<DataState<GetReverseCallsResponse>> getReverseCalls({
    required int page,
    required int pageSize,
  });

  Future<DataState> updateOnboardingStage({
    required String stage,
    required String date,
  });

  Future<DataState> markOnboardingStageCourseCompleted();

  Future<DataState> updateSupplyProfile({
    required String name,
    required String avatarUrl,
  });

  Future<DataState<FileResponseModel>> getOnboardingSelfie();

  Future<DataState<GetMeetingScheduleResponseModel>> getMeetingSchedule({
    required int page,
    required int pageSize,
  });

  Future<DataState<void>> markOnboardingCompleted();

  Future<DataState<RewardsStatsResponse>> getRewardsStats();

  Future<DataState<BaseResponseModel>> updateESign({
    required String transactionId,
    required String signedDocumentPath,
    required String maskedAadhar,
    required String name,
    required String ifsc,
    required String accountNumber,
    required String type,
    required String upi,
  });

  Future<DataState<OnboardingDetailsResponseModel>> getOnboardingDetails();
}
