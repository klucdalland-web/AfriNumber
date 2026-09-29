import 'package:get/get.dart';

import '../../data/repositories/mock_country_repository.dart';
import '../../domain/repositories/country_repository.dart';
import '../controllers/country_search_controller.dart';

class CountrySearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CountryRepository>(() => MockCountryRepository(), fenix: true);
    Get.lazyPut<CountrySearchController>(
      () => CountrySearchController(Get.find<CountryRepository>()),
      fenix: true,
    );
  }
}
