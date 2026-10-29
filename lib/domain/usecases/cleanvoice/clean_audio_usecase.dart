import 'dart:io';

import 'package:dio/dio.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/cleanvoice/create_edit_response.dart';
import 'package:voiceclub_partner/domain/repository/cleanvoice_repository.dart';

class CleanAudioUseCase
    implements UseCase<DataState<CreateEditResponse>, CleanAudioParams> {
  final CleanVoiceRepository _cleanVoiceRepository;

  CleanAudioUseCase(this._cleanVoiceRepository);

  @override
  Future<DataState<CreateEditResponse>> call(CleanAudioParams params) async {
    try {
      // Step 1: Get signed URL for upload
      final signedUrlResult = await _cleanVoiceRepository.getSignedUrl(
        filename: params.filename,
      );

      if (signedUrlResult is DataFailed) {
        return DataFailed(signedUrlResult.error!);
      }

      final signedUrl = (signedUrlResult as DataSuccess).data!.signedUrl;

      // Step 2: Upload file to signed URL
      final uploadResult = await _cleanVoiceRepository.uploadFileToSignedUrl(
        signedUrl: signedUrl,
        audioFile: params.audioFile,
      );

      if (uploadResult is DataFailed) {
        return DataFailed(uploadResult.error!);
      }

      // Step 3: Create edit job
      final editResult = await _cleanVoiceRepository.createEdit(
        fileUrl: signedUrl,
        config: params.config,
      );

      return editResult;
    } catch (e) {
      return DataFailed(
        DioException(
          requestOptions: RequestOptions(path: ''),
          error: 'Failed to clean audio: $e',
        ),
      );
    }
  }
}

class CleanAudioParams {
  final File audioFile;
  final String filename;
  final Map<String, dynamic>? config;

  const CleanAudioParams({
    required this.audioFile,
    required this.filename,
    this.config,
  });
}
