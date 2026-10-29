import 'package:dio/dio.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/http_response_handler.dart';
import 'package:voiceclub_partner/data/data_sources/remote/file/file_url_api_service.dart';
import 'package:voiceclub_partner/data/models/file/upload_file_response.dart';
import 'package:voiceclub_partner/domain/repository/file_url_repository.dart';

class FileUrlRepositoryImpl implements FileUrlRepository {
  final FileUrlApiService _fileUrlApiService;

  FileUrlRepositoryImpl(this._fileUrlApiService);

  @override
  Future<DataState<FileResponseModel>> getChatAttachmentUrl({
    required String filename,
  }) async {
    try {
      final response = await _fileUrlApiService.getChatAttachmentUrl(
        filename: filename,
      );
      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }
}
