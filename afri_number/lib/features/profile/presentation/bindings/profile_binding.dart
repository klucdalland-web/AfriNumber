import 'package:get/get.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/storage_service.dart';
import '../../../../core/utils/theme_controller.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/repositories/profil_repository_implement.dart';
import '../../domaine/profile_repository.dart';
import '../controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSource(
        Get.find<DioClient>(),
      ),
      fenix: true,
    );

    Get.lazyPut<ProfileRepository>(
      () => ProfilRepositoryImplement(
        Get.find<ProfileRemoteDataSource>(),
      ),
      fenix: true,
    );

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
