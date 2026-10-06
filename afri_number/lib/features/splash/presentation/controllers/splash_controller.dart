import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/services/firebase_notification_service.dart';
import '../../../../core/utils/auth_navigation.dart';
import '../../../../core/utils/storage_service.dart';

class SplashController extends GetxController {
  SplashController(this._storage, this._notifications);

  final StorageService _storage;
  final FirebaseNotificationService _notifications;

  @override
  void onInit() {
    super.onInit();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Permissions + token FCM avant navigation (login ou session existante).
    await _notifications.init();
    await _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    if (kDebugMode) {
      print("_checkAuthentication: Vérification du token...");
    }

    await Future.delayed(const Duration(seconds: 2));

    try {
      final pendingOtp = _storage.pendingOtp;
      if (pendingOtp != null &&
          (pendingOtp['purpose'] == 'login' ||
              pendingOtp['purpose'] == 'register') &&
          pendingOtp['identifier'] is String &&
          (pendingOtp['identifier'] as String).isNotEmpty) {
        Get.offAllNamed(AppRoutes.otpVerification);
        return;
      }

      if (_storage.hasToken) {
        final destination = AuthNavigation.homeRoute(_storage);
        if (kDebugMode) {
          print(
            '_checkAuthentication: Token trouvé -> Redirection vers $destination',
          );
        }
        // Fire-and-forget : ne bloque pas la navigation.
        _notifications.syncTokenWithBackend();
        Get.offAllNamed(destination);
      } else {
        if (kDebugMode) {
          print("_checkAuthentication: Aucun token -> Redirection vers Welcome");
        }
        Get.offAllNamed(AppRoutes.welcome);
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Splash auth check failed: $error\n$stackTrace');
      }
      Get.offAllNamed(AppRoutes.welcome);
    }
  }
}
