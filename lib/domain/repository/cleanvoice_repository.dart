import 'dart:io';

import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/data/models/cleanvoice/create_edit_response.dart';
import 'package:voiceclub_partner/data/models/cleanvoice/upload_response.dart';
import 'package:voiceclub_partner/data/models/cleanvoice/edit_response.dart';

abstract class CleanVoiceRepository {
  /// Get a signed URL for uploading an audio file
  Future<DataState<CleanVoiceUploadResponseModel>> getSignedUrl({
    required String filename,
  });

  /// Upload an audio file to the signed URL
  Future<DataState<void>> uploadFileToSignedUrl({
    required String signedUrl,
    required File audioFile,
  });

  /// Create an edit job for noise removal
  Future<DataState<CreateEditResponse>> createEdit({
    required String fileUrl,
    Map<String, dynamic>? config,
  });

  /// Get the status and result of an edit job
  Future<DataState<CleanVoiceEditResponseModel>> getEditStatus({
    required String editId,
  });

  /// Delete an edit job and its files
  Future<DataState<void>> deleteEdit({required String editId});
}
