import 'package:get/get.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/data/models/wallet/coins_result_wallet.dart';
import 'package:voiceclub_partner/domain/usecases/wallet/get_coins_transactions.dart';

class CoinsTransactionController extends GetxController {
  final coinBalance = 0.0.obs;
  final coinsTransactions = <CoinsResultWallet>{}.obs;
  final isLoading = false.obs; // Loading state variable
  int _totalPages = 1;

  @override
  void onInit() {
    fetchCoinsTransaction(1);
    super.onInit();
  }

  void fetchCoinsTransaction(int page, {bool isInit = false}) async {
    try {
      // Check if there are more pages to fetch
      if (page == 1) {
        if (!isInit) {
          coinsTransactions.clear();
        }
        _totalPages = 1;
      }
      if (page <= _totalPages) {
        isLoading.value = true; // Set loading state to true
        var response = await sl<GetCoinsTransactionsUseCase>().call(
          GetCoinsTransactionsParams(page: page, pageSize: 25),
        );
        // Add fetched transactions to the list
        coinsTransactions.addAll(response.data?.resultWallet ?? []);
        _totalPages = response.data?.totalPages ?? _totalPages;
      }
    } catch (_) {
    } finally {
      update();
      isLoading.value = false;
    }
  }
}
