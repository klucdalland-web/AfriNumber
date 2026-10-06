import 'package:get/get.dart';

import '../../../../core/services/firebase_notification_service.dart';
import '../../../../core/utils/storage_service.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SplashController>(
      SplashController(
        Get.find<StorageService>(),
        Get.find<FirebaseNotificationService>(),
        Get.find<AuthRepository>(),
      ),
    );
  }
}
