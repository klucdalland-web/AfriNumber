import 'package:get/get.dart';

import '../../data/repositories/mock_dashboard_repository.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../controllers/dashboard_controller.dart';

class DashboardBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardRepository>(
      () => MockDashboardRepository(),
      fenix: true,
    );
    Get.lazyPut<DashboardController>(
      () => DashboardController(Get.find<DashboardRepository>()),
      fenix: true,
    );
  }

}
