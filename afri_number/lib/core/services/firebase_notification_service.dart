import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';
import '../utils/storage_service.dart';

/// Uploads a fresh FCM token to the backend (`POST /devices/fcm-token`).
typedef FcmTokenUploader = Future<void> Function(String deviceId, String token);

/// Resolves the stable device id used when syncing the FCM token.
typedef DeviceIdResolver = Future<String?> Function();

/// Handler top-level requis pour les messages FCM en background / terminated.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    debugPrint('[FCM Background] Message reçu: ${message.messageId}');
  } catch (error, stackTrace) {
    debugPrint('[FCM Background] Initialization failed: $error\n$stackTrace');
  }
}

/// Service dédié aux notifications push Firebase Cloud Messaging.
///
/// Responsabilités :
/// - permissions (iOS + Android 13+)
/// - acquisition / cache / refresh du token FCM
/// - sync du token vers le backend
/// - écoute foreground, tap notification, message initial
class FirebaseNotificationService {
  FirebaseNotificationService(this._storage);

  final StorageService _storage;

  final _foregroundMessages = StreamController<RemoteMessage>.broadcast();
  final _openedMessages = StreamController<RemoteMessage>.broadcast();

  FcmTokenUploader? _uploader;
  DeviceIdResolver? _deviceIdResolver;
  bool _initialized = false;

  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedAppSub;

  /// Messages reçus pendant que l'app est au premier plan.
  Stream<RemoteMessage> get onForegroundMessage => _foregroundMessages.stream;

  /// Notifications ouvertes par l'utilisateur (app en background / terminated).
  Stream<RemoteMessage> get onNotificationOpened => _openedMessages.stream;

  /// Injecté après création des dépendances HTTP / device (évite les cycles).
  void bind({
    required DeviceIdResolver deviceIdResolver,
    required FcmTokenUploader uploader,
  }) {
    _deviceIdResolver = deviceIdResolver;
    _uploader = uploader;
  }

  /// Initialise permissions, token, et tous les listeners FCM.
  Future<void> init() async {
    if (kIsWeb || _initialized) return;

    try {
      final messaging = FirebaseMessaging.instance;

      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      // iOS : afficher les alertes aussi en foreground.
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      _tokenRefreshSub = messaging.onTokenRefresh.listen(
        _onTokenRefresh,
        onError: (Object error) {
          debugPrint('[FCM] token refresh error: $error');
        },
      );

      _foregroundSub = FirebaseMessaging.onMessage.listen(_onForegroundMessage);
      _openedAppSub =
          FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

      final initial = await messaging.getInitialMessage();
      if (initial != null) {
        _openedMessages.add(initial);
        if (kDebugMode) {
          debugPrint('[FCM] Opened from terminated: ${initial.messageId}');
        }
      }

      await _fetchAndCacheToken(messaging);
      _initialized = true;
      if (kDebugMode) debugPrint('[FCM] FirebaseNotificationService ready');
    } catch (e, st) {
      debugPrint('[FCM] init error: $e\n$st');
    }
  }

  /// Retourne un vrai FCM token, ou `null` si indisponible.
  Future<String?> getToken() async {
    try {
      final cached = _storage.fcmToken;
      if (cached != null && cached.isNotEmpty && !_isDummyToken(cached)) {
        return cached;
      }

      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty && !_isDummyToken(token)) {
        await _storage.saveFcmToken(token);
        return token;
      }
    } catch (e) {
      debugPrint('[FCM] getToken error: $e');
    }
    return null;
  }

  /// Pousse le token courant vers le backend si l'utilisateur est authentifié.
  Future<void> syncTokenWithBackend() async {
    if (!_storage.hasToken) return;

    final token = await getToken();
    if (token == null) return;

    final deviceId = await _deviceIdResolver?.call();
    if (deviceId == null || deviceId.isEmpty) return;

    final uploader = _uploader;
    if (uploader == null) return;

    try {
      await uploader(deviceId, token);
      if (kDebugMode) {
        debugPrint('[FCM] Token synced to backend for device $deviceId');
      }
    } catch (e) {
      debugPrint('[FCM] syncTokenWithBackend error: $e');
    }
  }

  Future<void> _fetchAndCacheToken(FirebaseMessaging messaging) async {
    try {
      final token = await messaging.getToken();
      if (token != null && token.isNotEmpty && !_isDummyToken(token)) {
        await _storage.saveFcmToken(token);
        if (kDebugMode) debugPrint('[FCM] Token acquired');
      }
    } catch (e) {
      debugPrint('[FCM] _fetchAndCacheToken error: $e');
    }
  }

  void _onTokenRefresh(String token) {
    if (_isDummyToken(token)) return;
    if (kDebugMode) debugPrint('[FCM] Token refreshed');
    _storage.saveFcmToken(token).then((_) {
      return syncTokenWithBackend();
    }).catchError((Object error) {
      debugPrint('[FCM] could not cache refreshed token: $error');
    });
  }

  void _onForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      debugPrint(
        '[FCM Foreground] id=${message.messageId} '
        'title=${message.notification?.title} '
        'body=${message.notification?.body}',
      );
    }
    _foregroundMessages.add(message);
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    if (kDebugMode) {
      debugPrint('[FCM Opened] id=${message.messageId} data=${message.data}');
    }
    _openedMessages.add(message);
  }

  static bool _isDummyToken(String token) =>
      token == 'dummy_fcm_token' || token.trim().isEmpty;

  void dispose() {
    _tokenRefreshSub?.cancel();
    _foregroundSub?.cancel();
    _openedAppSub?.cancel();
    _foregroundMessages.close();
    _openedMessages.close();
  }
}
