import 'package:get/get.dart';

import '../../data/models/billing_period.dart';
import '../../data/models/abonnement_checkout_result.dart';
import '../../data/models/abonnement_history_entry.dart';
import '../../data/models/abonnement_plan.dart';
import '../../domain/repositories/abonnement_repository.dart';

class AbonnementController extends GetxController {
  AbonnementController(this._repository);

  final AbonnementRepository _repository;

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final plans = <AbonnementPlan>[].obs;
  final history = <AbonnementHistoryEntry>[].obs;
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
      plans.assignAll(await _repository.fetchPlans());
      currentPlanId.value = plans
              .firstWhereOrNull((plan) => plan.currently)
              ?.id ??
          '';

      try {
        final serverCurrentPlanId = await _repository.fetchCurrentPlanId();
        if (serverCurrentPlanId.isNotEmpty) {
          currentPlanId.value = serverCurrentPlanId;
        }
      } catch (_) {
        // Le champ `currently` des plans reste utilisable si cet endpoint échoue.
      }

      try {
        history.assignAll(await _repository.fetchHistory());
      } catch (_) {
        history.clear();
      }
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
    } catch (_) {
      errorMessage.value = 'abonnement.retry_msg'.tr;
      return const AbonnementCheckoutResult(
        status: AbonnementCheckoutStatus.failed,
        message: null,
      );
    } finally {
      processingPlanId.value = null;
    }
  }
}
