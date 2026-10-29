import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/file/upload_file_response.dart';
import 'package:voiceclub_partner/domain/repository/call_logs_repository.dart';

class FetchLogRecordingUrlUsecase
    implements UseCase<DataState<FileResponseModel>, Params> {
  final CallLogsRepository _callLogsRepository;
  FetchLogRecordingUrlUsecase(this._callLogsRepository);

  @override
  Future<DataState<FileResponseModel>> call(Params params) {
    return _callLogsRepository.fetchLogRecordingUrl(filename: params.filename);
  }
}

class Params extends Equatable {
  final String filename;

  const Params({required this.filename});

  @override
  List<Object> get props => [filename];
}
