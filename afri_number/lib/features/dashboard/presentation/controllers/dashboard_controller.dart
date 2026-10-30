import 'package:get/get.dart';

import '../../domain/models/offer_item.dart';
import '../../domain/models/transaction_item.dart';
import '../../domain/repositories/dashboard_repository.dart';

class DashboardController extends GetxController {
  DashboardController(this._repository);

  final DashboardRepository _repository;

  final userCountry = 'Madagascar'.obs;
  final currencyName = 'Dollar américain'.obs;
  final balanceAmount = '£ 12,289.98'.obs;
  final virtualNumber = '**** 9548'.obs;
  final expirationDate = '25/08'.obs;
  final isBalanceHidden = false.obs;
  final recentTransactions = <TransactionItem>[].obs;
  final recommendedOffers = <OfferItem>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  void toggleBalanceVisibility() => isBalanceHidden.toggle();

  Future<void> loadDashboardData() async {
    if (isLoading.value) return;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final transactions = await _repository.fetchRecentTransactions();
      final offers = await _repository.fetchRecommendedOffers();
      recentTransactions.assignAll(transactions);
      recommendedOffers.assignAll(offers);
    } catch (_) {
      errorMessage.value = 'dashboard.load_error'.tr;
    } finally {
      isLoading.value = false;
    }
  }
}
