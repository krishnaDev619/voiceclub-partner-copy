import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/metrics/get_metrics_score.dart';
import 'package:voiceclub_partner/domain/repository/probation_repository.dart';

class GetMetricsScoreUseCase
    implements
        UseCase<DataState<GetMetricsScoreResponse>, GetMetricsScoreParams> {
  final MetricsRepository _probationRepository;

  GetMetricsScoreUseCase(this._probationRepository);

  @override
  Future<DataState<GetMetricsScoreResponse>> call(
    GetMetricsScoreParams params,
  ) {
    return _probationRepository.getMetricsScore(scoreOnly: params.scoreOnly);
  }
}

class GetMetricsScoreParams extends Equatable {
  final bool scoreOnly;

  const GetMetricsScoreParams({required this.scoreOnly});

  @override
  List<Object> get props => [scoreOnly];
}
