import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/account_repository.dart';

class UpdateStatusUsecase implements UseCase<DataState<void>, Params> {
  final AccountRepository _supplyAccountRepository;
  UpdateStatusUsecase(this._supplyAccountRepository);

  @override
  Future<DataState<void>> call(Params params) {
    return _supplyAccountRepository.updateStatus(params.isOnline);
  }
}

class Params extends Equatable {
  final bool isOnline;

  const Params({required this.isOnline});

  @override
  List<Object> get props => [isOnline];
}
