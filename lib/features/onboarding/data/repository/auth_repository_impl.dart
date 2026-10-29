import 'package:dio/dio.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/features/onboarding/data/data_sources/auth/auth_api_service.dart';
import 'package:voiceclub_partner/features/onboarding/data/models/auth/profile_response.dart';
import 'package:voiceclub_partner/features/onboarding/data/models/auth/verify_otp_response.dart';
import 'package:voiceclub_partner/features/onboarding/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService _authApiService;

  AuthRepositoryImpl(this._authApiService);

  @override
  Future<DataState> register({
    required String phoneNumber,
    String? gaid,
  }) async {
    try {
      final response = await _authApiService.register(
        phoneNumber: phoneNumber,
        gaid: gaid?.isNotEmpty == true ? gaid : null,
      );

      if (response.response.statusCode == 200) {
        return DataSuccess(response.data);
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
  Future<DataState<VerifyOtpResponseModel>> verifyOTP({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      final response = await _authApiService.verifyOTP(
        phoneNumber: phoneNumber,
        otp: otp,
      );

      if (response.response.statusCode == 200) {
        return DataSuccess(response.data);
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
  Future<DataState<ProfileResponseModel>> getProfile() async {
    try {
      final response = await _authApiService.getProfile();

      if (response.response.statusCode == 200) {
        return DataSuccess(response.data);
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
}
