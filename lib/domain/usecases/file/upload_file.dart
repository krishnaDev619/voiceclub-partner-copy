import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/file/upload_file_response.dart';
import 'package:voiceclub_partner/domain/repository/file_repository.dart';

class UploadFileUsecase
    implements UseCase<DataState<FileResponseModel>, UploadFileParams> {
  final FileRepository _fileRepository;
  UploadFileUsecase(this._fileRepository);

  @override
  Future<DataState<FileResponseModel>> call(UploadFileParams params) {
    return _fileRepository.uploadFile(recordingFile: params.recordingFile);
  }
}

class UploadFileParams extends Equatable {
  final File recordingFile;
  const UploadFileParams({required this.recordingFile});

  @override
  List<Object> get props => [recordingFile];
}
