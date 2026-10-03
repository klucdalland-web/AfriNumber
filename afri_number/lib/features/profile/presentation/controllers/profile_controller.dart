import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/utils/storage_service.dart';
import '../../../../core/utils/theme_controller.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../data/models/user_profile.dart';
import '../../domaine/profile_repository.dart';

class ProfileController extends GetxController {
  ProfileController(
    this._storage,
    this._themeController,
    this._authRepository,
    this._profileRepository,
  );

  final StorageService _storage;
  final ThemeController _themeController;
  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;

  final profile = UserProfile.sample.obs;
  final isLoading = false.obs;
  final notificationsEnabled = true.obs;
  final language = 'Français'.obs;

  bool get isDark => _themeController.isDark;

  @override
  void onInit() {
    super.onInit();
    _loadUserFromStorage();
    fetchProfileFromApi();
  }

  void _loadUserFromStorage() {
    final userMap = _storage.user;
    if (userMap != null) {
      profile.value = UserProfile.fromJson(userMap);
    }
  }

  Future<void> fetchProfileFromApi() async {
    isLoading.value = true;
    try {
      final userProfile = await _profileRepository.getProfile();
      profile.value = userProfile;
      if (kDebugMode) {
        print('=== ProfileController Loaded Profile ===');
        print(userProfile.toString());
      }
    } catch (e) {
      if (kDebugMode) {
        print('ProfileController error fetching profile: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  void toggleNotifications() => notificationsEnabled.toggle();

  void toggleTheme() {
    _themeController.toggle();
    update();
  }

  Future<void> signOut() async {
    await _authRepository.logout();
    Get.offAllNamed(AppRoutes.welcome);
  }
}
