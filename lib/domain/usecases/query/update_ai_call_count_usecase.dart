import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/query_repository.dart';

class UpdateAiCallCountUseCase
    implements UseCase<DataState<void>, UpdateAiCallCountParams> {
  final QueryRepository _queryRepository;

  UpdateAiCallCountUseCase(this._queryRepository);

  @override
  Future<DataState<void>> call(UpdateAiCallCountParams params) async {
    return _queryRepository.updateAiCallCount(sessionId: params.sessionId);
  }
}

class UpdateAiCallCountParams extends Equatable {
  final String sessionId;

  const UpdateAiCallCountParams({required this.sessionId});
  @override
  List<Object?> get props => [sessionId];
}
