import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/kyc_remote_datasource.dart';
import '../../data/repositories/kyc_repository_implement.dart';
import '../../data/repositories/mock_kyc_repository.dart';
import '../../domain/repositories/kyc_repository.dart';
import '../controllers/kyc_controller.dart';

/// Injection des dépendances de la feature KYC.
class KycBinding extends Bindings {
  /// Passe à `true` pour travailler sans backend (mock).
  static const bool _useMock = false;

  @override
  void dependencies() {
    Get.lazyPut<KycRemoteDataSource>(
          () => KycRemoteDataSource(Get.find<DioClient>()),
      fenix: true,
    );
    Get.lazyPut<KycRepository>(
          () => _useMock
          ? MockKycRepository()
          : KycRepositoryImpl(Get.find<KycRemoteDataSource>()),
      fenix: true,
    );
    Get.lazyPut<KycController>(
          () => KycController(
        Get.find<KycRepository>(),
      ),
      fenix: true,
    );
  }
}
