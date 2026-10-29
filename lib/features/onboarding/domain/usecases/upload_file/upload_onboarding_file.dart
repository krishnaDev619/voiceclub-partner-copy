import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:path/path.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/features/onboarding/data/models/verify_gender/upload_file_response_model.dart';
import 'package:voiceclub_partner/features/onboarding/domain/repository/upload_file_repository.dart';

class UploadOnboardingFileUsecase
    implements
        UseCase<
          DataState<UploadFileResponseModel>,
          UploadOnboardingFileParams
        > {
  final UploadFileRepository _uploadFileUseCase;

  UploadOnboardingFileUsecase(this._uploadFileUseCase);

  @override
  Future<DataState<UploadFileResponseModel>> call(
    UploadOnboardingFileParams params,
  ) {
    return _uploadFileUseCase.uploadOnboardingFile(
      file: params.file,
      extension: extension(params.file.path).replaceAll('.', ''),
    );
  }
}

class UploadOnboardingFileParams extends Equatable {
  final File file;

  const UploadOnboardingFileParams({required this.file});

  @override
  List<Object> get props => [file];
}
