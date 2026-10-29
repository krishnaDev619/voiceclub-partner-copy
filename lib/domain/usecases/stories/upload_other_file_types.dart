import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/file/upload_file_response.dart';
import 'package:voiceclub_partner/domain/repository/stories_repository.dart';

class UploadOtherFileTypesUsecase
    implements UseCase<DataState<FileResponseModel>, Params> {
  final StoriesRepository _storiesRepository;
  UploadOtherFileTypesUsecase(this._storiesRepository);

  @override
  Future<DataState<FileResponseModel>> call(Params params) {
    return _storiesRepository.uploadOtherFileTypes(
      file: params.file,
      extension: params.extension,
    );
  }
}

class Params extends Equatable {
  final File file;
  final String extension;

  const Params({required this.file, required this.extension});

  @override
  List<Object> get props => [file, extension];
}
