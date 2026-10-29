import 'package:dio/dio.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/http_response_handler.dart';
import 'package:voiceclub_partner/data/data_sources/remote/wallet/wallet_api_service.dart';
import 'package:voiceclub_partner/data/models/base_response.dart';
import 'package:voiceclub_partner/data/models/wallet/fetch_transactions_response.dart';
import 'package:voiceclub_partner/data/models/wallet/get_coin_wallet.dart';
import 'package:voiceclub_partner/data/models/wallet/get_coins_transactions.dart';
import 'package:voiceclub_partner/data/models/wallet/get_milestone_earnings_response.dart';
import 'package:voiceclub_partner/data/models/wallet/get_overview_response.dart';
import 'package:voiceclub_partner/data/models/wallet/get_payout_breakdown.dart';
import 'package:voiceclub_partner/data/models/wallet/payout_count.dart';
import 'package:voiceclub_partner/data/models/wallet/result_wallet.dart';
import 'package:voiceclub_partner/data/models/wallet/transaction_details.dart';
import 'package:voiceclub_partner/data/models/wallet/wallet_detail.dart';
import 'package:voiceclub_partner/domain/repository/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletApiService _supplyWalletApiService;

  WalletRepositoryImpl(this._supplyWalletApiService);

  @override
  Future<DataState<FetchTransactionsResponseModel>> fetchTransactions({
    required String category,
    required String transactionType,
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await _supplyWalletApiService.fetchTransactions(
        category: category,
        page: page,
        pageSize: pageSize,
        transactionType: transactionType,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<GetOverviewResponseModel>> getOverview({
    required String period,
  }) async {
    try {
      final response = await _supplyWalletApiService.getOverview(
        period: period,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<WalletDetail>> getWalletDetail() async {
    try {
      final response = await _supplyWalletApiService.getWalletDetail();

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<TransactionDetailsModel>> getTransactionDetails({
    required int id,
  }) async {
    try {
      final response = await _supplyWalletApiService.getTransactionDetails(
        id: id,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<GetPayoutBreakdownResponse>> getPayoutBreakdown({
    required int id,
  }) async {
    try {
      final response = await _supplyWalletApiService.getPayoutBreakdown(id: id);

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<GetMilestoneEarningsResponseModel>>
  getMilestoneEarnings() async {
    try {
      final response = await _supplyWalletApiService.getMilestoneEarnings();

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<GetCoinWalletResponse>> getCoinBalance() async {
    try {
      final response = await _supplyWalletApiService.getCoinBalance();

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<GetCoinsTransactions>> getCoinTransactions({
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await _supplyWalletApiService.getCoinTransactions(
        page: page,
        pageSize: pageSize,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<PayoutCountResponse>> getPayoutCount() async {
    try {
      final response = await _supplyWalletApiService.getPayoutCount();

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<ResultWalletModel>> getRecentPayout() async {
    try {
      final response = await _supplyWalletApiService.getRecentPayout();

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<BaseResponseModel>> withdrawPayout() async {
    try {
      final response = await _supplyWalletApiService.withdrawPayout();

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }
}
