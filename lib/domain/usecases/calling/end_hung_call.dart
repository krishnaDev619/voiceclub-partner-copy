import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/calling_repository.dart';

class EndHungCallUseCase implements UseCase<DataState, Params> {
  final CallingRepository _callingRepository;

  EndHungCallUseCase(this._callingRepository);

  @override
  Future<DataState> call(Params params) {
    return _callingRepository.endHungCall(channelId: params.channelId);
  }
}

class Params {
  final String channelId;

  const Params({required this.channelId});
}
