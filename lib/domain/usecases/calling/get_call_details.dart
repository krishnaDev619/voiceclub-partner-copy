import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/calling/call_details_response.dart';
import 'package:voiceclub_partner/domain/repository/calling_repository.dart';

class GetCallDetailsUsecase
    implements UseCase<DataState<GetCallDetailsResponseModel>, Params> {
  final CallingRepository _callingRepository;
  GetCallDetailsUsecase(this._callingRepository);

  @override
  Future<DataState<GetCallDetailsResponseModel>> call(Params params) {
    return _callingRepository.getCallDetails(channelId: params.channelId);
  }
}

class Params extends Equatable {
  final String channelId;

  const Params({required this.channelId});

  @override
  List<Object> get props => [channelId];
}
