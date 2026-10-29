import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/file/upload_file_response.dart';
import 'package:voiceclub_partner/domain/repository/stories_repository.dart';

class UploadStoryAudioFileUsecase
    implements UseCase<DataState<FileResponseModel>, Params> {
  final StoriesRepository _storiesRepository;
  UploadStoryAudioFileUsecase(this._storiesRepository);

  @override
  Future<DataState<FileResponseModel>> call(Params params) {
    return _storiesRepository.uploadStoryAudioFile(params.recordingFile);
  }
}

class Params extends Equatable {
  final File recordingFile;

  const Params({required this.recordingFile});

  @override
  List<Object> get props => [recordingFile];
}
