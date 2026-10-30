import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Service collectant les métadonnées d'appareil.
///
/// Le token FCM est fourni par [bindFcmTokenProvider] et inclus dans [collect]
/// uniquement s'il est réel.
class DeviceInfoService {
  Map<String, String>? _cachedDeviceInfo;
  Future<String?> Function()? _fcmTokenProvider;

  /// Injecté après création de FirebaseNotificationService.
  void bindFcmTokenProvider(Future<String?> Function() provider) {
    _fcmTokenProvider = provider;
  }

  /// Collecte les métadonnées d'appareil + le FCM token (si disponible).
  Future<Map<String, String>> collect() async {
    final fcmToken = await _fcmTokenProvider?.call();

    if (_cachedDeviceInfo != null) {
      return {
        ..._cachedDeviceInfo!,
        'fcm_token': ?fcmToken,
      };
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

    return {
      ..._cachedDeviceInfo!,
      'fcm_token': ?fcmToken,
    };
  }

  /// Retourne le même identifiant stable que celui envoyé à l'authentification.
  Future<String?> getDeviceId() async {
    final deviceInfo = _cachedDeviceInfo ?? await collect();
    final deviceId = deviceInfo['device_id']?.trim();
    return deviceId == null || deviceId.isEmpty ? null : deviceId;
  }
}
