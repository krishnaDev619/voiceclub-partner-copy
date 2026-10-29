import 'package:dio/dio.dart';
import 'package:voiceclub_partner/features/onboarding/core/constants/enums.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/features/onboarding/data/data_sources/update_data/update_data_api_service.dart';
import 'package:voiceclub_partner/features/onboarding/data/models/update_data/get_file_url_response.dart';
import 'package:voiceclub_partner/features/onboarding/data/models/update_data/onboarding_data_model.dart';
import 'package:voiceclub_partner/features/onboarding/domain/repository/update_data_repository.dart';

class UpdateDataRepositoryImpl implements UpdateDataRepository {
  final UpdateDataApiService _updateDataApiService;

  UpdateDataRepositoryImpl(this._updateDataApiService);

  @override
  Future<DataState> updateData(OnboardingDataModel updateDataModel) async {
    try {
      final response = await _updateDataApiService.updateData(
        name: updateDataModel.name ?? "",
        phone: updateDataModel.phone ?? "",
        firstLanguage: updateDataModel.firstLanguage ?? "",
        secondLanguage: updateDataModel.secondLanguage ?? "",
        maritalStatus: updateDataModel.maritalStatus ?? "",
        imagePath: updateDataModel.imagePath ?? "",
        hasPan: updateDataModel.hasPan ?? false,
        hasAadhar: updateDataModel.hasAadhar ?? false,
        age: updateDataModel.age ?? "",
        education: updateDataModel.education ?? "",
        religion: updateDataModel.religion ?? "",
        city: updateDataModel.city ?? "",
        state: updateDataModel.state ?? "",
        profileStatus:
            updateDataModel.profileStatus?.profileStatusToString ?? "",
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
  Future<DataState> updateSignDocument({
    required String documentPath,
    required String phoneNumber,
  }) async {
    try {
      final response = await _updateDataApiService.updateSignDocument(
        phoneNumber: phoneNumber,
        documentPath: documentPath,
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
  Future<DataState<GetFileUrlResponseModel>> getFileUrl({
    required String fileName,
  }) async {
    try {
      final response = await _updateDataApiService.getFileUrlRoute(
        fileName: fileName,
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
  Future<DataState> updateProfileStatus({
    required String phone,
    required String profileStatus,
  }) async {
    try {
      final response = await _updateDataApiService.updateProfileStatus(
        phone: phone,
        profileStatus: profileStatus,
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
  Future<DataState> completeOnboarding({
    required String phone,
    required bool bypassKyc,
  }) async {
    try {
      final response = await _updateDataApiService.completeOnboarding(
        phone: phone,
        bypassKyc: bypassKyc,
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
