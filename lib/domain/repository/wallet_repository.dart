import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/data/models/base_response.dart';
import 'package:voiceclub_partner/data/models/wallet/get_coin_wallet.dart';
import 'package:voiceclub_partner/data/models/wallet/get_coins_transactions.dart';
import 'package:voiceclub_partner/data/models/wallet/get_milestone_earnings_response.dart';
import 'package:voiceclub_partner/data/models/wallet/get_payout_breakdown.dart';
import 'package:voiceclub_partner/data/models/wallet/payout_count.dart';
import 'package:voiceclub_partner/data/models/wallet/result_wallet.dart';
import 'package:voiceclub_partner/data/models/wallet/transaction_details.dart';

import '../../data/models/wallet/fetch_transactions_response.dart';
import '../../data/models/wallet/get_overview_response.dart';
import '../../data/models/wallet/wallet_detail.dart';

abstract class WalletRepository {
  Future<DataState<FetchTransactionsResponseModel>> fetchTransactions({
    required String category,
    required int page,
    required int pageSize,
    required String transactionType,
  });

  Future<DataState<WalletDetail>> getWalletDetail();

  Future<DataState<GetOverviewResponseModel>> getOverview({
    required String period,
  });

  Future<DataState<TransactionDetailsModel>> getTransactionDetails({
    required int id,
  });

  Future<DataState<GetPayoutBreakdownResponse>> getPayoutBreakdown({
    required int id,
  });

  Future<DataState<GetMilestoneEarningsResponseModel>> getMilestoneEarnings();

  Future<DataState<GetCoinWalletResponse>> getCoinBalance();

  Future<DataState<GetCoinsTransactions>> getCoinTransactions({
    required int page,
    required int pageSize,
  });

  Future<DataState<PayoutCountResponse>> getPayoutCount();

  Future<DataState<ResultWalletModel>> getRecentPayout();

  Future<DataState<BaseResponseModel>> withdrawPayout();
}
