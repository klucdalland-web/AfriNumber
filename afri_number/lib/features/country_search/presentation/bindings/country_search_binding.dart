import 'package:get/get.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/datasources/country_remote_datasource.dart';
import '../../data/repositories/country_repository_impl.dart';
import '../../domain/repositories/country_repository.dart';
import '../controllers/country_search_controller.dart';

/// Injection de dépendances pour la feature CountrySearch.
/// Utilise l'implémentation réelle [CountryRepositoryImpl] branchée sur
/// [CountryRemoteDataSource] → GET `/pays`.
class CountrySearchBinding extends Bindings {
  @override
  void dependencies() {
    // DataSource — dépend du client Dio partagé
    Get.lazyPut<CountryRemoteDataSource>(
      () => CountryRemoteDataSource(Get.find<DioClient>()),
      fenix: true,
    );

    // Repository — dépend de la datasource
    Get.lazyPut<CountryRepository>(
      () => CountryRepositoryImpl(Get.find<CountryRemoteDataSource>()),
      fenix: true,
    );

    // Controller — dépend du repository
    Get.lazyPut<CountrySearchController>(
      () => CountrySearchController(Get.find<CountryRepository>()),
      fenix: true,
    );
  }
}
