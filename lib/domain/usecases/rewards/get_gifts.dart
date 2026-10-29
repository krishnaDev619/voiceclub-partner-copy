import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/rewards/get_gifts.dart';
import 'package:voiceclub_partner/domain/repository/rewards_repository.dart';

class GetGiftsUseCase
    implements UseCase<DataState<GetGiftsResponse>, NoParams> {
  final RewardsRepository _rewardsRepository;

  GetGiftsUseCase(this._rewardsRepository);

  @override
  Future<DataState<GetGiftsResponse>> call(NoParams params) async {
    return _rewardsRepository.getGifts();
  }
}
