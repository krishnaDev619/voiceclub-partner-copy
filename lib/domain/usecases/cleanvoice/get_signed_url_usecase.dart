import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/cleanvoice/upload_response.dart';
import 'package:voiceclub_partner/domain/repository/cleanvoice_repository.dart';

class GetSignedUrlUseCase
    implements
        UseCase<DataState<CleanVoiceUploadResponseModel>, GetSignedUrlParams> {
  final CleanVoiceRepository _cleanVoiceRepository;

  GetSignedUrlUseCase(this._cleanVoiceRepository);

  @override
  Future<DataState<CleanVoiceUploadResponseModel>> call(
    GetSignedUrlParams params,
  ) {
    return _cleanVoiceRepository.getSignedUrl(filename: params.filename);
  }
}

class GetSignedUrlParams {
  final String filename;

  const GetSignedUrlParams({required this.filename});
}
