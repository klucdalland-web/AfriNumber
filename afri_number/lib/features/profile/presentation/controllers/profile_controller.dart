import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/utils/storage_service.dart';
import '../../../../core/utils/theme_controller.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../data/models/user_profile.dart';

class ProfileController extends GetxController {
  ProfileController(this._storage, this._themeController, this._authRepository);

  final StorageService _storage;
  final ThemeController _themeController;
  final AuthRepository _authRepository;

  final profile = UserProfile.sample.obs;
  final notificationsEnabled = true.obs;
  final language = 'Français'.obs;

  bool get isDark => _themeController.isDark;

  @override
  void onInit() {
    super.onInit();
    _loadUserFromStorage();
  }

  void _loadUserFromStorage() {
    final userMap = _storage.user;
    if (userMap != null) {
      final name = userMap['name'] as String? ?? '';
      final firstName = userMap['first_name'] as String? ?? '';
      final fullName = '$firstName $name'.trim();

      profile.value = UserProfile(
        fullName: fullName.isNotEmpty ? fullName : 'Membre AfriNumber',
        username: (userMap['email'] as String? ?? '@user').split('@').first,
        phoneNumber: userMap['phone_number'] as String? ?? '+261 34 00 000 00',
        email: userMap['email'] as String? ?? 'support@afrinumber.com',
        countryName: 'Madagascar',
        countryCode: 'MG',
        activeNumbers: 2,
        planName: 'Offre Pro',
        countriesCount: 4,
      );
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
