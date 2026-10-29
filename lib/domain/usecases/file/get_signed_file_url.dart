import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/file/upload_file_response.dart';
import 'package:voiceclub_partner/domain/repository/file_repository.dart';

class GetSignedFileUrlUsecase
    implements UseCase<DataState<FileResponseModel>, Params> {
  final FileRepository _fileRepository;
  GetSignedFileUrlUsecase(this._fileRepository);

  @override
  Future<DataState<FileResponseModel>> call(Params params) {
    return _fileRepository.getSignedFileUrl(fileName: params.fileName);
  }
}

class Params extends Equatable {
  final String fileName;
  const Params({required this.fileName});

  @override
  List<Object?> get props => [fileName];
}
