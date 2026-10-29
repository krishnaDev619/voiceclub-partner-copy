import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/wallet/transaction_details.dart';
import 'package:voiceclub_partner/domain/repository/wallet_repository.dart';

class GetTransactionDetailsUseCase
    implements UseCase<DataState<TransactionDetailsModel>, Params> {
  final WalletRepository _walletRepository;

  GetTransactionDetailsUseCase(this._walletRepository);

  @override
  Future<DataState<TransactionDetailsModel>> call(Params params) {
    return _walletRepository.getTransactionDetails(id: params.id);
  }
}

class Params extends Equatable {
  final int id;

  const Params({required this.id});

  @override
  List<Object> get props => [id];
}
