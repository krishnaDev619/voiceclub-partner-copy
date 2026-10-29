import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/cleanvoice/create_edit_response.dart';
import 'package:voiceclub_partner/domain/repository/cleanvoice_repository.dart';

class CreateEditUseCase
    implements UseCase<DataState<CreateEditResponse>, CreateEditParams> {
  final CleanVoiceRepository _cleanVoiceRepository;

  CreateEditUseCase(this._cleanVoiceRepository);

  @override
  Future<DataState<CreateEditResponse>> call(CreateEditParams params) {
    return _cleanVoiceRepository.createEdit(
      fileUrl: params.fileUrl,
      config: params.config,
    );
  }
}

class CreateEditParams {
  final String fileUrl;
  final Map<String, dynamic>? config;

  const CreateEditParams({required this.fileUrl, this.config});
}
