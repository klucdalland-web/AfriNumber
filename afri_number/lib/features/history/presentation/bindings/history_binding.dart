import 'package:get/get.dart';

import '../../data/repositories/history_repository.dart';
import '../../data/repositories/mock_history_repository.dart';
import '../controllers/history_controller.dart';

class HistoryBinding extends Bindings {
  @override
  void dependencies() {
    // Point de bascule mock → API : remplacer MockHistoryRepository.
    Get.lazyPut<HistoryRepository>(() => MockHistoryRepository(), fenix: true);
    Get.lazyPut<HistoryController>(
      () => HistoryController(Get.find<HistoryRepository>()),
      fenix: true,
    );
  }
}
