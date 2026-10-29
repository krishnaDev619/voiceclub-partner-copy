import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/calling/get_hung_call.dart';
import 'package:voiceclub_partner/domain/repository/calling_repository.dart';

class GetHungCallUseCase
    implements UseCase<DataState<GetHungCallModel>, NoParams> {
  final CallingRepository _callingRepository;

  GetHungCallUseCase(this._callingRepository);

  @override
  Future<DataState<GetHungCallModel>> call(NoParams params) {
    return _callingRepository.getHungCall();
  }
}
