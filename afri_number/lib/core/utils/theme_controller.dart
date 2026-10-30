import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../constants/storage_keys.dart';
import 'storage_service.dart';

/// Gestion du thème (light / dark / system) avec persistance.
class ThemeController extends GetxController {
  ThemeController(this._storage);

  final StorageService _storage;

  final themeMode = ThemeMode.system.obs;

  @override
  void onInit() {
    super.onInit();
    themeMode.value = _readMode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.changeThemeMode(themeMode.value);
    });
  }

  ThemeMode _readMode() {
    final raw = _storage.read<String>(StorageKeys.themeMode);
    return switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    Get.changeThemeMode(mode);
    try {
      await _storage.write(StorageKeys.themeMode, mode.name);
    } catch (error) {
      if (kDebugMode) debugPrint('[ThemeController] Save theme failed: $error');
    }
  }

  /// Alterne light ↔ dark (ignore system pour le toggle bouton).
  Future<void> toggle() async {
    final isDark = themeMode.value == ThemeMode.dark ||
        (themeMode.value == ThemeMode.system &&
            Get.isPlatformDarkMode);
    await setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
  }

  bool get isDark {
    if (themeMode.value == ThemeMode.dark) return true;
    if (themeMode.value == ThemeMode.light) return false;
    return Get.isPlatformDarkMode;
  }
}
