import 'package:get/get.dart';

import '../../data/models/billing_period.dart';
import '../../data/models/abonnement_checkout_result.dart';
import '../../data/models/abonnement_plan.dart';
import '../../data/repositories/abonnement_repository.dart';

class AbonnementController extends GetxController {
  AbonnementController(this._repository);

  final AbonnementRepository _repository;

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final plans = <AbonnementPlan>[].obs;
  final period = BillingPeriod.annual.obs;
  final currentPlanId = ''.obs;
  final processingPlanId = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final results = await Future.wait([
        _repository.fetchPlans(),
        _repository.fetchCurrentPlanId(),
      ]);
      plans.assignAll(results[0] as List<AbonnementPlan>);
      currentPlanId.value = results[1] as String;
    } catch (_) {
      errorMessage.value = 'Impossible de charger les offres. Réessayez.';
    } finally {
      isLoading.value = false;
    }
  }

  void selectPeriod(BillingPeriod value) => period.value = value;

  Future<AbonnementCheckoutResult> subscribe(String planId) async {
    processingPlanId.value = planId;
    try {
      final result = await _repository.subscribe(
        planId: planId,
        period: period.value,
      );
      if (result.status == AbonnementCheckoutStatus.success) {
        currentPlanId.value = planId;
      }
      return result;
    } finally {
      processingPlanId.value = null;
    }
  }
}
