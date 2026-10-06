import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/utils/storage_service.dart';
import '../../../../core/utils/theme_controller.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../data/models/user_profile.dart';

/// Contrôleur gérant la logique de l'onglet Profil et l'affichage des informations utilisateur.
class ProfileController extends GetxController {
  ProfileController(this._storage, this._themeController, this._authRepository);

  final StorageService _storage;
  final ThemeController _themeController;
  final AuthRepository _authRepository;

  /// Observable contenant le profil de l'utilisateur connecté.
  final profile = UserProfile.sample.obs;

  /// État des notifications
  final notificationsEnabled = true.obs;

  /// Langue sélectionnée
  final language = 'Français'.obs;

  /// Indicateur de chargement / rafraîchissement
  final isRefreshing = false.obs;

  /// Indique qu'une déconnexion est en cours.
  final isSigningOut = false.obs;

  /// Retourne vrai si le thème sombre est actif
  bool get isDark => _themeController.isDark;

  @override
  void onInit() {
    super.onInit();
    // 1. Chargement synchrone depuis le stockage local (GetStorage) pour affichage immédiat
    _loadUserFromStorage();
    // 2. Récupération des données fraîches depuis l'API en arrière-plan
    refreshProfile();
  }

  /// Charge les données utilisateur préalablement sauvegardées dans le stockage local.
  void _loadUserFromStorage() {
    final userMap = _storage.user;
    if (userMap != null) {
      profile.value = UserProfile.fromJson(userMap);
    }
  }

  /// Récupère le profil mis à jour depuis le serveur (`/auth/user` / `/auth/me`),
  /// enregistre les nouvelles données en local et rafraîchit l'UI.
  Future<void> refreshProfile() async {
    try {
      isRefreshing.value = true;
      final userMap = await _authRepository.me();
      if (userMap != null && userMap.isNotEmpty) {
        await _storage.saveUser(userMap);
        profile.value = UserProfile.fromJson(userMap);
        if (kDebugMode) {
          debugPrint('[ProfileController] Profil utilisateur synchronisé avec l\'API.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ProfileController] Erreur lors du rafraîchissement du profil: $e');
      }
    } finally {
      isRefreshing.value = false;
    }
  }

  /// Bascule l'activation des notifications
  void toggleNotifications() => notificationsEnabled.toggle();

  /// Bascule le thème de l'application (Clair / Sombre)
  void toggleTheme() {
    _themeController.toggle();
    update();
  }

  /// Déconnecte l'utilisateur et le redirige vers l'écran d'accueil
  Future<void> signOut() async {
    if (isSigningOut.value) return;
    isSigningOut.value = true;
    try {
      await _authRepository.logout();
    } catch (error) {
      if (kDebugMode) debugPrint('[ProfileController] Sign out failed: $error');
    } finally {
      Get.offAllNamed(AppRoutes.welcome);
    }
  }
}
