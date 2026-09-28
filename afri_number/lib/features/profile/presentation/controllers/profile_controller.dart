import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../data/models/user_profile.dart';

/// État de l'écran Profil — interface seule : données d'exemple et réglages
/// locaux, sans repository ni appel réseau.
class ProfileController extends GetxController {
  final profile = UserProfile.sample.obs;
  final notificationsEnabled = true.obs;

  /// `true` = thème clair (libellé « Clair »), `false` = « Sombre ».
  final isLightTheme = true.obs;
  final language = 'Français'.obs;

  void toggleNotifications() => notificationsEnabled.toggle();

  void toggleTheme() => isLightTheme.toggle();

  /// TODO(backend): appeler `AuthRepository.logout()` et purger les tokens
  /// avant de quitter. Pour l'instant : retour à l'écran d'accueil.
  void signOut() => Get.offAllNamed(AppRoutes.welcome);
}
