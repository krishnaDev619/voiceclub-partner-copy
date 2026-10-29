import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/account/get_audio_status_response.dart';
import 'package:voiceclub_partner/domain/repository/account_repository.dart';

class GetAudioStatusUsecase
    implements UseCase<DataState<GetAudioStatusResponseModel>, NoParams> {
  final AccountRepository _accountRepository;
  GetAudioStatusUsecase(this._accountRepository);

  @override
  Future<DataState<GetAudioStatusResponseModel>> call(NoParams params) {
    return _accountRepository.getAudioStatus();
  }
}
