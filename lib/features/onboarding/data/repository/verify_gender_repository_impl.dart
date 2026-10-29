import 'package:dio/dio.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/features/onboarding/data/data_sources/verify_gender/verify_gender_api_service.dart';
import 'package:voiceclub_partner/features/onboarding/data/models/verify_gender/verify_gender_response_model.dart';
import 'package:voiceclub_partner/features/onboarding/domain/repository/verify_gender_repository.dart';

class VerifyGenderRepositoryImpl implements VerifyGenderRepository {
  final VerifyGenderApiService _verifyGenderApiService;

  VerifyGenderRepositoryImpl(this._verifyGenderApiService);

  @override
  Future<DataState<VerifyGenderResponseModel>> verifyGender({
    required Map<String, dynamic> s3Object,
  }) async {
    try {
      final response = await _verifyGenderApiService.verifyGender(
        s3Object: s3Object,
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
}
