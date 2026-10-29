import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/cleanvoice/edit_response.dart';
import 'package:voiceclub_partner/domain/repository/cleanvoice_repository.dart';

class GetEditStatusUseCase
    implements
        UseCase<DataState<CleanVoiceEditResponseModel>, GetEditStatusParams> {
  final CleanVoiceRepository _cleanVoiceRepository;

  GetEditStatusUseCase(this._cleanVoiceRepository);

  @override
  Future<DataState<CleanVoiceEditResponseModel>> call(
    GetEditStatusParams params,
  ) {
    return _cleanVoiceRepository.getEditStatus(editId: params.editId);
  }
}

class GetEditStatusParams {
  final String editId;

  const GetEditStatusParams({required this.editId});
}
