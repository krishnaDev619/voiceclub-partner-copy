import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/gifts/can_receive_gifts_response.dart';
import 'package:voiceclub_partner/domain/repository/gifts_repository.dart';

class CanReceiveGiftsUsecase
    implements UseCase<DataState<CanReceiveGiftsResponseModel>, Params> {
  final GiftsRepository _giftsRepository;
  CanReceiveGiftsUsecase(this._giftsRepository);

  @override
  Future<DataState<CanReceiveGiftsResponseModel>> call(Params params) {
    return _giftsRepository.canReceiveGifts(
      receiverAccountId: params.receiverAccountId,
      senderAccountId: params.senderAccountId,
    );
  }
}

class Params extends Equatable {
  final int receiverAccountId;
  final int senderAccountId;
  const Params({
    required this.receiverAccountId,
    required this.senderAccountId,
  });

  @override
  List<Object?> get props => [receiverAccountId, senderAccountId];
}
