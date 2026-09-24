import 'package:get/get.dart';

import '../../core/network/dio_client.dart';
import '../../core/utils/storage_service.dart';
import '../../core/utils/theme_controller.dart';

/// Bindings globaux (services partagés : storage, HTTP, thème…).
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<StorageService>(StorageService(), permanent: true);
    Get.put<DioClient>(DioClient(Get.find<StorageService>()), permanent: true);
    Get.put<ThemeController>(
      ThemeController(Get.find<StorageService>()),
      permanent: true,
    );
  }
}
