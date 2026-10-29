import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/file/upload_file_response.dart';
import 'package:voiceclub_partner/domain/repository/file_url_repository.dart';

class GetChatAttachmentUrlUseCase
    implements
        UseCase<DataState<FileResponseModel>, GetChatAttachmentUrlParams> {
  final FileUrlRepository _fileUrlRepository;

  GetChatAttachmentUrlUseCase(this._fileUrlRepository);

  @override
  Future<DataState<FileResponseModel>> call(GetChatAttachmentUrlParams params) {
    return _fileUrlRepository.getChatAttachmentUrl(filename: params.filename);
  }
}

class GetChatAttachmentUrlParams {
  final String filename;

  const GetChatAttachmentUrlParams({required this.filename});
}
