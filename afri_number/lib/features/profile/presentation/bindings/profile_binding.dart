import 'package:get/get.dart';

import '../../../../core/utils/storage_service.dart';
import '../../../../core/utils/theme_controller.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(
      () => ProfileController(
        Get.find<StorageService>(),
        Get.find<ThemeController>(),
        Get.find<AuthRepository>(),
      ),
      fenix: true,
    );
  }
}
