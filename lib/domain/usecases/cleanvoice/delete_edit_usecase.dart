import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/cleanvoice_repository.dart';

class DeleteEditUseCase implements UseCase<DataState<void>, DeleteEditParams> {
  final CleanVoiceRepository _cleanVoiceRepository;

  DeleteEditUseCase(this._cleanVoiceRepository);

  @override
  Future<DataState<void>> call(DeleteEditParams params) {
    return _cleanVoiceRepository.deleteEdit(editId: params.editId);
  }
}

class DeleteEditParams {
  final String editId;

  const DeleteEditParams({required this.editId});
}
