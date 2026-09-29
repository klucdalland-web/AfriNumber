import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../constants/storage_keys.dart';
import '../utils/storage_service.dart';
import 'app_translations.dart';

/// Gestion de la langue (fr / en) avec persistance.
class LocaleController extends GetxController {
  LocaleController(this._storage);

  final StorageService _storage;

  final locale = AppTranslations.fallbackLocale.obs;

  @override
  void onInit() {
    super.onInit();
    locale.value = _read();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.updateLocale(locale.value);
    });
  }

  Locale _read() {
    final raw = _storage.read<String>(StorageKeys.language);
    if (raw == null || raw.isEmpty) return _platformLocale();
    return AppTranslations.localeFor(raw);
  }

  /// Détecte la langue système si aucune préférence enregistrée.
  Locale _platformLocale() {
    final device = Get.deviceLocale;
    if (device != null &&
        AppTranslations.supportedLanguageCodes.contains(device.languageCode)) {
      return AppTranslations.localeFor(device.languageCode);
    }
    return AppTranslations.fallbackLocale;
  }

  String get languageCode => locale.value.languageCode;
  bool get isFrench => languageCode == 'fr';

  Future<void> change(String code) async {
    if (!AppTranslations.supportedLanguageCodes.contains(code)) return;
    final next = AppTranslations.localeFor(code);
    locale.value = next;
    await Get.updateLocale(next);
    await _storage.write(StorageKeys.language, code);
  }
}