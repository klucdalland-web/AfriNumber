import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/storage_keys.dart';
import '../utils/storage_service.dart';

class LocalizationService {
  static Locale get currentLocale {
    if (!Get.isRegistered<StorageService>()) return const Locale('fr', 'FR');
    final storage = Get.find<StorageService>();
    final langCode = storage.read<String>(StorageKeys.language);
    if (langCode == 'en') return const Locale('en', 'US');
    return const Locale('fr', 'FR');
  }

  static Future<void> changeLocale(String langCode) async {
    final locale = langCode == 'en' ? const Locale('en', 'US') : const Locale('fr', 'FR');
    await Get.updateLocale(locale);
    if (Get.isRegistered<StorageService>()) {
      await Get.find<StorageService>().write(StorageKeys.language, langCode);
    }
  }
}
