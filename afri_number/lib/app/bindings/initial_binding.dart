import 'package:get/get.dart';

import '../../core/network/dio_client.dart';
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
    Get.lazyPut<StorageService>(() => StorageService(), fenix: true);
    Get.lazyPut<DioClient>(() => DioClient(Get.find<StorageService>()), fenix: true);
    Get.lazyPut<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(Get.find<DioClient>(), Get.find<StorageService>()),
      fenix: true,
    );
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(Get.find<AuthRemoteDataSource>(), Get.find<StorageService>()),
      fenix: true,
    );
    Get.lazyPut<AuthController>(
      () => AuthController(Get.find<AuthRepository>()),
      fenix: true,
    );
    Get.lazyPut<ThemeController>(
      () => ThemeController(Get.find<StorageService>()),
      fenix: true,
    );
  }
}
