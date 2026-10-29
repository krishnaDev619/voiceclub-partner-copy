import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/call_logs/fetch_call_logs_for_pair_response.dart';
import 'package:voiceclub_partner/domain/repository/call_logs_repository.dart';

class FetchCallLogsForPairUsecase
    implements UseCase<DataState<FetchCallLogsForPairResponseModel>, Params> {
  final CallLogsRepository _callLogsRepository;
  FetchCallLogsForPairUsecase(this._callLogsRepository);

  @override
  Future<DataState<FetchCallLogsForPairResponseModel>> call(Params params) {
    return _callLogsRepository.fetchCallLogsForPair(
      userId: params.userId,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class Params extends Equatable {
  final int userId, page, pageSize;

  const Params({
    required this.userId,
    required this.page,
    required this.pageSize,
  });

  @override
  List<Object> get props => [userId, page, pageSize];
}
