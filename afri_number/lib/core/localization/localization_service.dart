import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../constants/storage_keys.dart';
import '../utils/storage_service.dart';
import 'app_translations.dart';

class LocalizationService {
  static Locale get currentLocale {

    final code = GetStorage().read<String>(StorageKeys.language);
    return AppTranslations.localeFor(code ?? '');
  }

  static Future<void> changeLocale(String langCode) async {
    final locale = langCode == 'en' ? const Locale('en', 'US') : const Locale('fr', 'FR');
    await Get.updateLocale(locale);
    if (Get.isRegistered<StorageService>()) {
      await Get.find<StorageService>().write(StorageKeys.language, langCode);
    }
  }
}
