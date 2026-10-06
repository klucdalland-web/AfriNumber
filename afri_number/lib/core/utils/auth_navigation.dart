import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/profile/data/models/user_profile.dart';
import 'storage_service.dart';

/// Redirection post-auth selon `status_valide`.
class AuthNavigation {
  AuthNavigation._();

  /// `true` si l'utilisateur local a `status_valide == valide`.
  static bool isUserValidated([StorageService? storage]) {
    final box = storage ?? Get.find<StorageService>();
    final raw = box.user;
    if (raw == null) return false;
    return UserModel.fromJson(raw).isValidated;
  }

  /// Route d'accueil : Main si validé, sinon KYC (blocage identité).
  static String homeRoute([StorageService? storage]) =>
      isUserValidated(storage) ? AppRoutes.main : AppRoutes.kyc;

  /// Remplace la pile par la bonne route d'accueil.
  static void goToHome([StorageService? storage]) {
    Get.offAllNamed(homeRoute(storage));
  }

  /// Rafraîchit le profil depuis `/auth/me` avant de choisir l'écran.
  ///
  /// En cas d'échec réseau, conserve le cache local (ne bloque pas le boot).
  static Future<void> syncSessionBeforeRouting({
    StorageService? storage,
    AuthRepository? authRepository,
  }) async {
    final box = storage ?? Get.find<StorageService>();
    if (!box.hasToken) return;

    try {
      final repo = authRepository ?? Get.find<AuthRepository>();
      final userMap = await repo.me();
      if (userMap != null && userMap.isNotEmpty) {
        await box.saveUser(userMap);
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '[AuthNavigation] syncSessionBeforeRouting failed: $error\n$stackTrace',
        );
      }
    }
  }

  /// Marque le compte local comme validé puis ouvre Main.
  static Future<void> completeKycAndEnterApp([StorageService? storage]) async {
    final box = storage ?? Get.find<StorageService>();
    final current = box.user;
    final Map<String, dynamic> updated = current == null
        ? <String, dynamic>{'status_valide': 'valide'}
        : (Map<String, dynamic>.from(current)..['status_valide'] = 'valide');
    await box.saveUser(updated);
    Get.offAllNamed(AppRoutes.main);
  }
}
