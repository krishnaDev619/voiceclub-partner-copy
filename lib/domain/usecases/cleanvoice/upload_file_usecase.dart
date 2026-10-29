import 'dart:io';

import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/cleanvoice_repository.dart';

class UploadFileUseCase implements UseCase<DataState<void>, UploadFileParams> {
  final CleanVoiceRepository _cleanVoiceRepository;

  UploadFileUseCase(this._cleanVoiceRepository);

  @override
  Future<DataState<void>> call(UploadFileParams params) {
    return _cleanVoiceRepository.uploadFileToSignedUrl(
      signedUrl: params.signedUrl,
      audioFile: params.audioFile,
    );
  }
}

class UploadFileParams {
  final String signedUrl;
  final File audioFile;

  const UploadFileParams({required this.signedUrl, required this.audioFile});
}
