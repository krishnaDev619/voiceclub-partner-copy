import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/data/models/file/upload_file_response.dart';

abstract class FileUrlRepository {
  Future<DataState<FileResponseModel>> getChatAttachmentUrl({
    required String filename,
  });
}
