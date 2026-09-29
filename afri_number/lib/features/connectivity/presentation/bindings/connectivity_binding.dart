import 'package:get/get.dart';

import '../../data/repositories/connectivity_repository.dart';
import '../../data/repositories/mock_connectivity_repository.dart';
import '../controllers/connectivity_controller.dart';

class ConnectivityBinding extends Bindings {
  @override
  void dependencies() {
    // Point de bascule mock → API : remplacer MockConnectivityRepository.
    Get.lazyPut<ConnectivityRepository>(
      () => MockConnectivityRepository(),
      fenix: true,
    );
    Get.lazyPut<ConnectivityController>(
      () => ConnectivityController(Get.find<ConnectivityRepository>()),
      fenix: true,
    );
  }
}
