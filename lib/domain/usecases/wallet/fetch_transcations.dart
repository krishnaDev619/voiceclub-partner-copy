import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/wallet/fetch_transactions_response.dart';
import 'package:voiceclub_partner/domain/repository/wallet_repository.dart';

class FetchTranscationsUseCase
    implements UseCase<DataState<FetchTransactionsResponseModel>, Params> {
  final WalletRepository _walletRepository;
  FetchTranscationsUseCase(this._walletRepository);

  @override
  Future<DataState<FetchTransactionsResponseModel>> call(Params params) {
    return _walletRepository.fetchTransactions(
      category: params.category.name,
      transactionType: params.transactionType.name,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class Params extends Equatable {
  final CategoryOption category;
  final TransactionCategory transactionType;
  final int page, pageSize;
  const Params({
    required this.category,
    required this.page,
    required this.pageSize,
    required this.transactionType,
  });

  @override
  List<Object> get props => [category, page, pageSize, transactionType];
}
