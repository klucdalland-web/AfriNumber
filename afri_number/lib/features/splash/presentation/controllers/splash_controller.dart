import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/utils/storage_service.dart';

class SplashController extends GetxController {
  SplashController(this._storage);

  final StorageService _storage;

  @override
  void onReady() {
    super.onReady();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    await Future.delayed(const Duration(milliseconds: 1800));

    if (_storage.hasToken) {
      Get.offAllNamed(AppRoutes.main);
    } else {
      Get.offAllNamed(AppRoutes.welcome);
    }
  }
}
