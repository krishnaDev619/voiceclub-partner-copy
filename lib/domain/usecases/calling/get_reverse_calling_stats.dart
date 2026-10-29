import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/calling/get_reverse_calling_stats_reponse.dart';
import 'package:voiceclub_partner/domain/repository/calling_repository.dart';

class GetReverseCallingStatsUsecase
    implements
        UseCase<
          DataState<GetReverseCallingStatsResponseModel>,
          GetReverseCallingStatsParams
        > {
  final CallingRepository _callingRepository;
  GetReverseCallingStatsUsecase(this._callingRepository);

  @override
  Future<DataState<GetReverseCallingStatsResponseModel>> call(
    GetReverseCallingStatsParams params,
  ) {
    return _callingRepository.getReverseCallingStats(
      demandAccountId: params.demandAccountId,
    );
  }
}

class GetReverseCallingStatsParams extends Equatable {
  final int demandAccountId;

  const GetReverseCallingStatsParams({required this.demandAccountId});

  @override
  List<Object> get props => [demandAccountId];
}
