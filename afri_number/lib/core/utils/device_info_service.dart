import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'package:package_info_plus/package_info_plus.dart';

import 'storage_service.dart';

/// Service collectant les informations d'appareil et le FCM token.
///
/// Le FCM token est :
///   1. Demandé à Firebase Messaging (avec permission sur iOS)
///   2. Mis en cache dans [StorageService] pour être réutilisé sans rappel réseau
///   3. Inclus dans chaque payload d'authentification (login / register)
class DeviceInfoService {
  DeviceInfoService(this._storage);

  final StorageService _storage;

  Map<String, String>? _cachedDeviceInfo;

  // ── FCM ────────────────────────────────────────────────────────────────────

  /// Initialise les permissions FCM (iOS uniquement) et écoute les
  /// rafraîchissements de token pour mettre à jour le cache local.
  Future<void> initFcm() async {
    if (kIsWeb) return; // La gestion Web FCM est gérée séparément

    try {
      final messaging = FirebaseMessaging.instance;

      // Sur iOS, demander les permissions push
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      // Rafraîchissement automatique du token
      FirebaseMessaging.instance.onTokenRefresh.listen((token) {
        _onTokenRefresh(token);
      }, onError: (Object error) {
        debugPrint('[DeviceInfoService] token refresh error: $error');
      });

      // Récupération initiale
      await _fetchAndCacheFcmToken(messaging);
    } catch (e) {
      debugPrint('[DeviceInfoService] initFcm error: $e');
    }
  }

  /// Retourne le FCM token le plus récent :
  ///   - Depuis le cache mémoire si disponible
  ///   - Sinon depuis GetStorage
  ///   - Sinon depuis Firebase (avec fallback 'dummy_fcm_token' pour éviter le rejet backend)
  Future<String> getFcmToken() async {
    try {
      final cached = _storage.fcmToken;
      if (cached != null && cached.isNotEmpty && cached != 'dummy_fcm_token') {
        return cached;
      }
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await _storage.saveFcmToken(token);
        return token;
      }
    } catch (e) {
      debugPrint('[DeviceInfoService] getFcmToken error: $e');
    }
    return 'dummy_fcm_token';
  }

  Future<void> _fetchAndCacheFcmToken(FirebaseMessaging messaging) async {
    try {
      final token = await messaging.getToken();
      if (token != null && token.isNotEmpty) {
        await _storage.saveFcmToken(token);
        if (kDebugMode) {
          debugPrint('[FCM] Token: $token');
        }
      }
    } catch (e) {
      debugPrint('[DeviceInfoService] _fetchAndCacheFcmToken error: $e');
    }
  }

  void _onTokenRefresh(String token) {
    if (kDebugMode) debugPrint('[FCM] Token refreshed: $token');
    _storage.saveFcmToken(token).catchError((Object error) {
      debugPrint('[DeviceInfoService] could not cache refreshed FCM token: $error');
    });
  }

  // ── Device info ────────────────────────────────────────────────────────────

  /// Collecte toutes les métadonnées d'appareil + le FCM token.
  /// Les informations d'appareil sont mises en cache entre les appels ;
  /// le FCM token est toujours résolu dynamiquement.
  Future<Map<String, String>> collect() async {
    final fcmToken = await getFcmToken();

    if (_cachedDeviceInfo != null) {
      return {..._cachedDeviceInfo!, 'fcm_token': fcmToken};
    }

    var platform = 'unknown';
    var deviceId = '';
    var deviceName = '';
    var deviceModel = '';
    var osVersion = '';
    var appVersion = '';

    try {
      appVersion = (await PackageInfo.fromPlatform()).version;
    } catch (e) {
      debugPrint('[DeviceInfoService] package info error: $e');
    }

    try {
      final deviceInfoPlugin = DeviceInfoPlugin();
      if (kIsWeb) {
        final info = await deviceInfoPlugin.webBrowserInfo;
        platform = 'web';
        deviceId = info.vendor ?? info.userAgent ?? 'web-device';
        deviceName = info.browserName.name;
        deviceModel = info.platform ?? 'web';
        osVersion = info.appVersion ?? '';
      } else {
        switch (defaultTargetPlatform) {
          case TargetPlatform.android:
            final info = await deviceInfoPlugin.androidInfo;
            platform = 'android';
            deviceId = info.id;
            deviceName = info.device;
            deviceModel = info.model;
            osVersion = info.version.release;
          case TargetPlatform.iOS:
            final info = await deviceInfoPlugin.iosInfo;
            platform = 'ios';
            deviceId = info.identifierForVendor ?? '';
            deviceName = info.name;
            deviceModel = info.utsname.machine;
            osVersion = info.systemVersion;
          default:
            platform = defaultTargetPlatform.name;
        }
      }
    } catch (e) {
      // Les métadonnées d'appareil ne doivent jamais bloquer l'auth.
      debugPrint('[DeviceInfoService] collect device info error: $e');
    }

    _cachedDeviceInfo = {
      'platform': platform,
      'device_id': deviceId,
      'device_name': deviceName,
      'device_model': deviceModel,
      'os_version': osVersion,
      'app_version': appVersion,
    };

    return {..._cachedDeviceInfo!, 'fcm_token': fcmToken};
  }

  /// Retourne le même identifiant stable que celui envoyé à l'authentification.
  Future<String?> getDeviceId() async {
    final deviceInfo = _cachedDeviceInfo ?? await collect();
    final deviceId = deviceInfo['device_id']?.trim();
    return deviceId == null || deviceId.isEmpty ? null : deviceId;
  }
}
