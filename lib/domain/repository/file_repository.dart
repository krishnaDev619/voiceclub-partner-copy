import 'dart:io';

import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/data/models/file/upload_file_response.dart';

abstract class FileRepository {
  Future<DataState<FileResponseModel>> uploadFile({
    required File recordingFile,
  });
  Future<DataState<FileResponseModel>> getSignedFileUrl({
    required String fileName,
  });
}
