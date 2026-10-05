import 'package:get/get.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/datasources/abonnement_remote_datasource.dart';
import '../../domain/repositories/abonnement_repository.dart';
import '../../data/repositories/abonnement_repository_impl.dart';
import '../controllers/abonnement_controller.dart';

class AbonnementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AbonnementRemoteDataSource>(
      () => AbonnementRemoteDataSource(Get.find<DioClient>()),
      fenix: true,
    );
    Get.lazyPut<AbonnementRepository>(
      () => AbonnementRepositoryImpl(Get.find<AbonnementRemoteDataSource>()),
      fenix: true,
    );
    Get.lazyPut<AbonnementController>(
      () => AbonnementController(Get.find<AbonnementRepository>()),
      fenix: true,
    );
  }
}
