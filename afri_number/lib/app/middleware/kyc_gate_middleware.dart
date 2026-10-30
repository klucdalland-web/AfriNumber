import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/utils/auth_navigation.dart';
import '../../core/utils/storage_service.dart';
import '../routes/app_routes.dart';

/// Empêche l'accès à Main tant que `status_valide` n'est pas `valide`.
class KycGateMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<StorageService>()) return null;
    if (AuthNavigation.isUserValidated()) return null;
    return const RouteSettings(name: AppRoutes.kyc);
  }
}
