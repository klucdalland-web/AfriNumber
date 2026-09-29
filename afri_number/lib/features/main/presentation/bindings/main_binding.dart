import 'package:get/get.dart';

import '../../../../app/bindings/account_tabs_binding.dart';
import '../controllers/main_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>(() => MainController());
    AccountTabsBinding().dependencies();
  }
}
