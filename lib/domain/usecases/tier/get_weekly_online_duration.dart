import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/tier/get_weekly_online_duration_response.dart';
import 'package:voiceclub_partner/domain/repository/tier_repository.dart';

class GetWeeklyOnlineDurationUsecase
    implements
        UseCase<DataState<GetWeeklyOnlineDurationResponseModel>, NoParams> {
  final TierRepository _tierRepository;
  GetWeeklyOnlineDurationUsecase(this._tierRepository);

  @override
  Future<DataState<GetWeeklyOnlineDurationResponseModel>> call(
    NoParams params,
  ) async {
    return _tierRepository.getWeeklyOnlineDuration();
  }
}
