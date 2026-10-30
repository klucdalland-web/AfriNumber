import 'package:get/get.dart';

import '../../../../core/utils/storage_service.dart';
import '../../data/models/billing_period.dart';
import '../../data/models/abonnement_checkout_result.dart';
import '../../data/models/abonnement_history_entry.dart';
import '../../data/models/abonnement_plan.dart';
import '../../domain/repositories/abonnement_repository.dart';

class AbonnementController extends GetxController {
  AbonnementController(this._repository, this._storage);

  final AbonnementRepository _repository;
  final StorageService _storage;

  String get countryCode {
    final user = _storage.user;
    final country = user?['pays'] ?? user?['country'];
    final code = country is Map ? country['code']?.toString().trim() : null;
    return code == null || code.isEmpty ? 'MG' : code.toUpperCase();
  }

  final isLoading = false.obs;
  final isHistoryLoading = false.obs;
  final errorMessage = ''.obs;
  final historyErrorMessage = ''.obs;
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

    } catch (_) {
      errorMessage.value = 'abonnement.load_error'.tr;
    } finally {
      isLoading.value = false;
    }
    await loadHistory();
  }

  Future<void> loadHistory() async {
    isHistoryLoading.value = true;
    historyErrorMessage.value = '';
    try {
      history.assignAll(await _repository.fetchHistory());
    } catch (_) {
      historyErrorMessage.value = 'abonnement.history_error'.tr;
    } finally {
      isHistoryLoading.value = false;
    }
  }

  Future<AbonnementCheckoutResult> subscribe(
    String planId, {
    String? countryCode,
    String? operator,
    String? phone,
  }) async {
    processingPlanId.value = planId;
    try {
      final result = await _repository.subscribe(
        planId: planId,
        period: period.value,
        countryCode: countryCode,
        operator: operator,
        phone: phone,
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
