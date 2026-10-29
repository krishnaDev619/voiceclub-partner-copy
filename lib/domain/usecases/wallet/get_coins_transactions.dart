import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/wallet/get_coins_transactions.dart';
import 'package:voiceclub_partner/domain/repository/wallet_repository.dart';

class GetCoinsTransactionsUseCase
    implements
        UseCase<DataState<GetCoinsTransactions>, GetCoinsTransactionsParams> {
  final WalletRepository _walletRepository;
  GetCoinsTransactionsUseCase(this._walletRepository);

  @override
  Future<DataState<GetCoinsTransactions>> call(
    GetCoinsTransactionsParams params,
  ) {
    return _walletRepository.getCoinTransactions(
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class GetCoinsTransactionsParams extends Equatable {
  final int page, pageSize;

  const GetCoinsTransactionsParams({
    required this.page,
    required this.pageSize,
  });

  @override
  List<Object> get props => [page, pageSize];
}
