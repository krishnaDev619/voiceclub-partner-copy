import 'package:dio/dio.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/http_response_handler.dart';
import 'package:voiceclub_partner/data/data_sources/remote/account/account_api_service.dart';
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
import 'package:voiceclub_partner/domain/repository/account_repository.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountApiService _supplyAccountApiService;

  AccountRepositoryImpl(this._supplyAccountApiService);

  @override
  Future<DataState<DataModel>> getSupplyProfile() async {
    try {
      final response = await _supplyAccountApiService.getSupplyProfile();

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<void>> updateRecording({
    required String url,
    required String type,
    required String language,
    required String status,
    String? reason,
  }) async {
    try {
      final response = await _supplyAccountApiService.updateRecording(
        url: url,
        type: type,
        language: language,
        status: status,
        reason: reason,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<void>> updateStatus(bool isOnline) async {
    try {
      final response = await _supplyAccountApiService.updateStatus(isOnline);

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<GetAccountPreferenceResponseModel>>
  getAccountPreference() async {
    try {
      final response = await _supplyAccountApiService.getAccountPreference();

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<void>> updateAccountPreference({
    required String callPreference,
    required String chatPreference,
  }) async {
    try {
      final response = await _supplyAccountApiService.updateAccountPreference(
        callPreference: callPreference,
        chatPreference: chatPreference,
      );

      if (response.response.statusCode == 200) {
        return const DataSuccess(null);
      } else {
        return DataFailed(
          DioException(
            error: response.response.statusCode,
            message: response.response.statusMessage,
            response: response.response,
            requestOptions: response.response.requestOptions,
          ),
        );
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<GetAudioStatusResponseModel>> getAudioStatus() async {
    try {
      final response = await _supplyAccountApiService.getAudioStatus();

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<GetCurrentOnlineDurationResponseModel>>
  getCurrentOnlineDuration() async {
    try {
      final response =
          await _supplyAccountApiService.getCurrentOnlineDuration();

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<GetCriteriaUsersResponseModel>> getCriteriaUsers({
    required int cutoffFlag,
    String? searchQuery,
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await _supplyAccountApiService.getCriteriaUsers(
        cutoffFlag: cutoffFlag,
        page: page,
        pageSize: pageSize,
        searchQuery: searchQuery,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<void>> updateLanguage({
    required String firstLanguage,
    required String secondLanguage,
  }) async {
    try {
      final response = await _supplyAccountApiService.updateLanguage(
        firstLanguage: firstLanguage,
        secondLanguage: secondLanguage,
      );

      if (response.response.statusCode == 200) {
        return const DataSuccess(null);
      } else {
        return DataFailed(
          DioException(
            error: response.response.statusCode,
            message: response.response.statusMessage,
            response: response.response,
            requestOptions: response.response.requestOptions,
          ),
        );
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<void>> updateNotificationPreference({
    required String notificationPreference,
  }) async {
    try {
      final response = await _supplyAccountApiService
          .updateNotificationPreference(
            notificationPreference: notificationPreference,
          );

      if (response.response.statusCode == 200) {
        return const DataSuccess(null);
      } else {
        return DataFailed(
          DioException(
            error: response.response.statusCode,
            message: response.response.statusMessage,
            response: response.response,
            requestOptions: response.response.requestOptions,
          ),
        );
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<void>> updateKYC({
    required String name,
    required String panImagePath,
    required String selfieImagePath,
    required String panNumber,
    required String ifsc,
    required String accountNumber,
    required bool isVerified,
  }) async {
    try {
      final response = await _supplyAccountApiService.updateKYC(
        name: name,
        panImagePath: panImagePath,
        selfieImagePath: selfieImagePath,
        panNumber: panNumber,
        ifsc: ifsc,
        accountNumber: accountNumber,
        isVerified: isVerified,
      );

      if (response.response.statusCode == 200) {
        return const DataSuccess(null);
      } else {
        return DataFailed(
          DioException(
            error: response.response.statusCode,
            message: response.response.statusMessage,
            response: response.response,
            requestOptions: response.response.requestOptions,
          ),
        );
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<GetKYCResponseModel>> getKYC() async {
    try {
      final response = await _supplyAccountApiService.getKYC();

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState> updateLocation({
    required String city,
    required String state,
  }) async {
    try {
      final response = await _supplyAccountApiService.updateLocation(
        city: city,
        state: state,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<GetReverseCallsResponse>> getReverseCalls({
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await _supplyAccountApiService.getReverseCalls(
        pageSize: pageSize,
        page: page,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState> updateOnboardingStage({
    required String stage,
    required String date,
  }) async {
    try {
      final response = await _supplyAccountApiService.updateOnboardingStage(
        stage: stage,
        date: date,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState> markOnboardingStageCourseCompleted() async {
    try {
      final response =
          await _supplyAccountApiService.markOnboardingStageCourseCompleted();

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState> updateSupplyProfile({
    required String name,
    required String avatarUrl,
  }) async {
    try {
      final response = await _supplyAccountApiService.updateSupplyProfile(
        name: name,
        avatarUrl: avatarUrl,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<FileResponseModel>> getOnboardingSelfie() async {
    try {
      final response = await _supplyAccountApiService.getOnboardingSelfie();

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<GetMeetingScheduleResponseModel>> getMeetingSchedule({
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await _supplyAccountApiService.getMeetingSchedule(
        page: page,
        pageSize: pageSize,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<void>> markOnboardingCompleted() async {
    try {
      final response = await _supplyAccountApiService.markOnboardingCompleted();

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<RewardsStatsResponse>> getRewardsStats() async {
    try {
      final response = await _supplyAccountApiService.getRewardsStats();

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<BaseResponseModel>> updateESign({
    required String transactionId,
    required String signedDocumentPath,
    required String maskedAadhar,
    required String name,
    required String ifsc,
    required String accountNumber,
    required String type,
    required String upi,
  }) async {
    try {
      final response = await _supplyAccountApiService.updateESign(
        name: name,
        maskedAadhar: maskedAadhar,
        signedDocumentPath: signedDocumentPath,
        transactionId: transactionId,
        ifsc: ifsc,
        accountNumber: accountNumber,
        type: type,
        upi: upi,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<OnboardingDetailsResponseModel>>
  getOnboardingDetails() async {
    try {
      final response = await _supplyAccountApiService.getOnboardingDetails();

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }
}
