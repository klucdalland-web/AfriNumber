import 'package:get/get.dart';

import '../../core/constants/api_constants.dart';
import '../../core/localization/locale_controller.dart';
import '../../core/network/dio_client.dart';
import '../../core/services/firebase_notification_service.dart';
import '../../core/utils/device_info_service.dart';
import '../../core/utils/storage_service.dart';
import '../../core/utils/theme_controller.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';

/// Bindings globaux (services partagés : storage, HTTP, thème…).
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // StorageService permanent : utilisé dès le SplashScreen, doit survivre
    // aux navigations (Get.offAllNamed efface les bindings non-permanents).
    Get.put<StorageService>(StorageService(), permanent: true);

    final deviceInfo = DeviceInfoService();
    Get.put<DeviceInfoService>(deviceInfo, permanent: true);

    // Notifications FCM : permanent pour garder les listeners vivants.
    final notifications = FirebaseNotificationService(Get.find<StorageService>());
    notifications.bind(
      deviceIdResolver: () => deviceInfo.getDeviceId(),
      uploader: (deviceId, token) async {
        await Get.find<DioClient>().post(
          ApiConstants.devicesFcmToken,
          data: {
            'device_id': deviceId,
            'token': token,
          },
        );
      },
    );
    deviceInfo.bindFcmTokenProvider(() => notifications.getToken());
    Get.put<FirebaseNotificationService>(notifications, permanent: true);

    Get.lazyPut<DioClient>(
      () => DioClient(
        Get.find<StorageService>(),
        Get.find<DeviceInfoService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(
        Get.find<DioClient>(),
        Get.find<StorageService>(),
        Get.find<DeviceInfoService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(
        Get.find<AuthRemoteDataSource>(),
        Get.find<StorageService>(),
      ),
      fenix: true,
    );
    Get.put<LocaleController>(
      LocaleController(Get.find<StorageService>()),
      permanent: true,
    );
    Get.lazyPut<AuthController>(
      () => AuthController(
        Get.find<AuthRepository>(),
        Get.find<StorageService>(),
        Get.find<FirebaseNotificationService>(),
      ),
      fenix: true,
    );
    Get.put<ThemeController>(
      ThemeController(Get.find<StorageService>()),
      permanent: true,
    );
  }
}
