import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/rewards_repository.dart';

class ClaimGiftUseCase implements UseCase<DataState<void>, ClaimGiftParams> {
  final RewardsRepository _rewardsRepository;

  ClaimGiftUseCase(this._rewardsRepository);

  @override
  Future<DataState<void>> call(ClaimGiftParams params) async {
    return _rewardsRepository.claimGift(
      giftId: params.giftId,
      type: params.type,
      address: params.address,
    );
  }
}

class ClaimGiftParams {
  final int giftId;
  final String type;
  final String address;

  ClaimGiftParams({
    required this.giftId,
    required this.type,
    required this.address,
  });
}
