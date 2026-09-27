import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';


class DeviceInfoService {
  Map<String, String>? _cached;

  String fcmToken = '';

  Future<Map<String, String>> collect() async {
    final cached = _cached;
    if (cached != null) {
      return {...cached, 'fcm_token': fcmToken};
    }

    final deviceInfoPlugin = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();

    var platform = 'unknown';
    var deviceId = '';
    var deviceName = '';
    var deviceModel = '';
    var osVersion = '';

    try {
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
            break;
          case TargetPlatform.iOS:
            final info = await deviceInfoPlugin.iosInfo;
            platform = 'ios';
            deviceId = info.identifierForVendor ?? '';
            deviceName = info.name;
            deviceModel = info.utsname.machine;
            osVersion = info.systemVersion;
            break;
          default:
            platform = defaultTargetPlatform.name;
        }
      }
    } catch (_) {
      // Les métadonnées d'appareil ne doivent jamais bloquer l'auth.
    }

    _cached = {
      'platform': platform,
      'device_id': deviceId,
      'device_name': deviceName,
      'device_model': deviceModel,
      'os_version': osVersion,
      'app_version': packageInfo.version,
    };
    return {..._cached!, 'fcm_token': fcmToken};
  }
}
