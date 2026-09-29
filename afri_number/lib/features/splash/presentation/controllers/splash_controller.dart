import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/utils/storage_service.dart';

class SplashController extends GetxController {
  SplashController(this._storage);

  final StorageService _storage;

  @override
  void onInit() {
    super.onInit();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    if (kDebugMode) {
      print("_checkAuthentication: Vérification du token...");
    }

    await Future.delayed(const Duration(seconds: 2));

    if (_storage.hasToken) {
      if (kDebugMode) {
        print("_checkAuthentication: Token trouvé -> Redirection vers Main");
      }
      Get.offAllNamed(AppRoutes.main);
    } else {
      if (kDebugMode) {
        print("_checkAuthentication: Aucun token -> Redirection vers Welcome");
      }
      Get.offAllNamed(AppRoutes.welcome);
    }
  }
}
