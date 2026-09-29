import 'package:get/get.dart';

import '../controllers/country_search_controller.dart';

class CountrySearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CountrySearchController>(
      () => CountrySearchController(),
      fenix: true,
    );
  }
}
