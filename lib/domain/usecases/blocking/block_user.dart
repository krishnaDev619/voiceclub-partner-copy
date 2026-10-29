import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/blocking_repository.dart';

class BlockUserUsecase implements UseCase<DataState<void>, Params> {
  final BlockingRepository _blockingRepository;
  BlockUserUsecase(this._blockingRepository);

  @override
  Future<DataState<void>> call(Params params) {
    return _blockingRepository.blockUser(params.accountId, params.reason);
  }
}

class Params extends Equatable {
  final int accountId;
  final String reason;
  const Params({required this.accountId, required this.reason});

  @override
  List<Object> get props => [accountId, reason];
}
