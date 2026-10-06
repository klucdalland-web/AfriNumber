import 'package:get_storage/get_storage.dart';

import '../constants/storage_keys.dart';

/// Service de stockage persistant local (basé sur [GetStorage]).
class StorageService {
  StorageService({GetStorage? box}) : _box = box ?? GetStorage();

  final GetStorage _box;

  Future<void> write(String key, dynamic value) => _box.write(key, value);

  T? read<T>(String key) => _box.read<T>(key);

  Future<void> remove(String key) => _box.remove(key);

  Future<void> clear() => _box.erase();

  // ── Token helpers ──────────────────────────────────────────────────────────

  /// Retourne le jeton d'accès enregistré dans GetStorage.
  /// Renvoie `null` si aucun token valide n'est présent (l'appelant doit
  /// rediriger vers la page de connexion dans ce cas).
  String? get accessToken {
    final token = read<String>(StorageKeys.accessToken);
    if (token != null && token.trim().isNotEmpty) return token;
    return null;
  }

  /// Retourne le jeton de renouvellement enregistré, s'il est présent.
  String? get refreshToken {
    final token = read<String>(StorageKeys.refreshToken);
    if (token != null && token.trim().isNotEmpty) return token;
    return null;
  }

  /// Indique si un jeton d'accès valide est présent.
  bool get hasToken {
    final t = accessToken;
    return t != null && t.trim().isNotEmpty;
  }

  /// Sauvegarde le jeton d'accès JWT dans le stockage local.
  Future<void> saveAccessToken(String token) =>
      write(StorageKeys.accessToken, token);

  Future<void> saveRefreshToken(String token) =>
      write(StorageKeys.refreshToken, token);

  /// Efface les jetons et les données utilisateur du stockage local.
  /// Le FCM token est conservé : il est lié à l'appareil, pas à la session.
  Future<void> clearTokens() async {
    await remove(StorageKeys.accessToken);
    await remove(StorageKeys.refreshToken);
    await remove(StorageKeys.user);
  }

  // ── User helpers ───────────────────────────────────────────────────────────

  /// Sauvegarde la Map des informations utilisateur dans le stockage local.
  Future<void> saveUser(Map<String, dynamic> userData) =>
      write(StorageKeys.user, userData);

  /// Récupère la Map des informations utilisateur conservée en cache.
  Map<String, dynamic>? get user {
    final raw = read(StorageKeys.user);
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  // ── FCM token helpers ──────────────────────────────────────────────────────

  /// Sauvegarde le FCM token dans le stockage local.
  Future<void> saveFcmToken(String token) =>
      write(StorageKeys.fcmToken, token);

  /// Récupère le FCM token mis en cache.
  String? get fcmToken => read<String>(StorageKeys.fcmToken);

  // ── Remember-me helpers ────────────────────────────────────────────────────

  /// Récupère le numéro de téléphone mémorisé.
  String? get rememberedPhone => read<String>(StorageKeys.rememberedPhone);

  /// Enregistre le numéro de téléphone mémorisé.
  Future<void> saveRememberedPhone(String phone) =>
      write(StorageKeys.rememberedPhone, phone);

  /// Efface le numéro mémorisé.
  Future<void> clearRememberedPhone() => remove(StorageKeys.rememberedPhone);

  Map<String, dynamic>? get pendingOtp {
    final value = read(StorageKeys.pendingOtp);
    return value is Map ? Map<String, dynamic>.from(value) : null;
  }

  Future<void> savePendingOtp({
    required String purpose,
    required String identifier,
    required int expiresAtMillis,
  }) => write(StorageKeys.pendingOtp, {
    'purpose': purpose,
    'identifier': identifier,
    'expires_at': expiresAtMillis,
  });

  Future<void> clearPendingOtp() => remove(StorageKeys.pendingOtp);
}
