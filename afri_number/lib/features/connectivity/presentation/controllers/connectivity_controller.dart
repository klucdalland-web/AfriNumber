import 'package:get/get.dart';

import '../../data/models/connectivity_service.dart';
import '../../data/models/data_plan.dart';
import '../../data/repositories/connectivity_repository.dart';

class ConnectivityController extends GetxController {
  ConnectivityController(this._repository);

  final ConnectivityRepository _repository;

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final zeroDataEnabled = false.obs;
  final services = <ConnectivityService>[].obs;
  final plans = <DataPlan>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final overview = await _repository.fetchOverview();
      zeroDataEnabled.value = overview.zeroDataEnabled;
      services.assignAll(overview.services);
      plans.assignAll(overview.plans);
    } catch (_) {
      errorMessage.value = 'error.services_load'.tr;
    } finally {
      isLoading.value = false;
    }
  }

  /// Bascule optimiste du mode Zéro Data, annulée si l'appel échoue.
  Future<void> toggleZeroData(bool enabled) async {
    final previous = zeroDataEnabled.value;
    zeroDataEnabled.value = enabled;
    try {
      await _repository.setZeroData(enabled);
    } catch (_) {
      zeroDataEnabled.value = previous;
      errorMessage.value = 'error.service_update'.tr;
    }
  }
}
