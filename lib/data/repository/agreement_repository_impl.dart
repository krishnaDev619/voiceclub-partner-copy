import 'package:dio/dio.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/http_response_handler.dart';
import 'package:voiceclub_partner/data/data_sources/remote/agreement/agreement_api_service.dart';
import 'package:voiceclub_partner/data/models/kyc_file/get_file_url.dart';
import 'package:voiceclub_partner/domain/repository/agreement_repository.dart';

class AgreementRepositoryImpl implements AgreementRepository {
  final AgreementApiService _agreementApiService;

  AgreementRepositoryImpl(this._agreementApiService);

  @override
  Future<DataState> updateSignDocument({
    required String documentPath,
    required String phoneNumber,
  }) async {
    try {
      final response = await _agreementApiService.updateSignDocument(
        phoneNumber: phoneNumber,
        documentPath: documentPath,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<GetFileUrlResponseModel>> getFileUrl({
    required String fileName,
  }) async {
    try {
      final response = await _agreementApiService.getFileUrl(
        fileName: fileName,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }
}
