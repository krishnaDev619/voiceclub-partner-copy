import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:voiceclub_partner/core/constants/api_constants.dart';
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

part 'wallet_api_service.g.dart';

@RestApi()
abstract class WalletApiService {
  factory WalletApiService(Dio dio) = _WalletApiService;

  @GET(APIConstants.fetchSupplyTransactionsRoute)
  Future<HttpResponse<FetchTransactionsResponseModel>> fetchTransactions({
    @Path('category') required String category,
    @Query('type') required String transactionType,
    @Query('page') required int page,
    @Query('page_size') required int pageSize,
  });

  @GET(APIConstants.getWalletDetailsRoute)
  Future<HttpResponse<WalletDetail>> getWalletDetail();

  @GET(APIConstants.getOverviewRoute)
  Future<HttpResponse<GetOverviewResponseModel>> getOverview({
    @Path('period') required String period,
  });

  @GET(APIConstants.getTransactionDetailsRoute)
  Future<HttpResponse<TransactionDetailsModel>> getTransactionDetails({
    @Path('id') required int id,
  });

  @GET(APIConstants.getPayoutBreakdownRoute)
  Future<HttpResponse<GetPayoutBreakdownResponse>> getPayoutBreakdown({
    @Path('id') required int id,
  });

  @GET(APIConstants.getMilestoneEarningsRoute)
  Future<HttpResponse<GetMilestoneEarningsResponseModel>>
  getMilestoneEarnings();

  @GET(APIConstants.getCoinBalanceRoute)
  Future<HttpResponse<GetCoinWalletResponse>> getCoinBalance();

  @GET(APIConstants.getCoinTransactionsRoute)
  Future<HttpResponse<GetCoinsTransactions>> getCoinTransactions({
    @Query('page') required int page,
    @Query('page_size') required int pageSize,
  });

  @GET(APIConstants.getPayoutCountRoute)
  Future<HttpResponse<PayoutCountResponse>> getPayoutCount();

  @GET(APIConstants.getRecentPayoutRoute)
  Future<HttpResponse<ResultWalletModel>> getRecentPayout();

  @POST(APIConstants.withdrawPayoutRoute)
  Future<HttpResponse<BaseResponseModel>> withdrawPayout();
}
