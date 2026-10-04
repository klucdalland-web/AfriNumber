import 'package:get_storage/get_storage.dart';

import '../constants/storage_keys.dart';

/// Service de stockage persistant local (basé sur [GetStorage]).
class StorageService {
  StorageService({GetStorage? box}) : _box = box ?? GetStorage();

  final GetStorage _box;

  /// Jeton d'accès de test fourni pour les appels d'API.
  static const String testToken = '51|dLGvspTdolVArWvNgWpSOVOgNYQfl3BSK8pEu11k184ada4d';

  Future<void> write(String key, dynamic value) => _box.write(key, value);

  T? read<T>(String key) => _box.read<T>(key);

  Future<void> remove(String key) => _box.remove(key);

  Future<void> clear() => _box.erase();

  // ── Token helpers ──

  /// Retourne le jeton d'accès enregistré dans GetStorage ou le jeton de test fourni.
  String? get accessToken {
    final token = read<String>(StorageKeys.accessToken);
    if (token != null && token.trim().isNotEmpty) {
      return token;
    }
    // Jeton de test par défaut pour l'authentification aux endpoints /auth/user & /auth/me
    return testToken;
  }

  /// Sauvegarde le jeton d'accès JWT dans le stockage local.
  Future<void> saveAccessToken(String token) =>
      write(StorageKeys.accessToken, token);

  /// Efface les jetons et les données utilisateur du stockage local.
  Future<void> clearTokens() async {
    await remove(StorageKeys.accessToken);
    await remove(StorageKeys.refreshToken);
    await remove(StorageKeys.user);
  }

  /// Sauvegarde la Map des informations utilisateur dans le stockage local.
  Future<void> saveUser(Map<String, dynamic> userData) =>
      write(StorageKeys.user, userData);

  /// Récupère la Map des informations utilisateur conservée en cache.
  Map<String, dynamic>? get user {
    final raw = read(StorageKeys.user);
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  /// Indique si un jeton d'accès est présent.
  bool get hasToken =>
      accessToken != null && accessToken!.trim().isNotEmpty;

  // ── Remember-me helpers ──

  /// Récupère le numéro de téléphone mémorisé
  String? get rememberedPhone => read<String>(StorageKeys.rememberedPhone);

  /// Enregistre le numéro de téléphone mémorisé
  Future<void> saveRememberedPhone(String phone) =>
      write(StorageKeys.rememberedPhone, phone);

  /// Efface le numéro mémorisé
  Future<void> clearRememberedPhone() => remove(StorageKeys.rememberedPhone);
}
