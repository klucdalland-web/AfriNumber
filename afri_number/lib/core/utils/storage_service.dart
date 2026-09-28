import 'package:get_storage/get_storage.dart';

import '../constants/storage_keys.dart';

class StorageService {
  StorageService({GetStorage? box}) : _box = box ?? GetStorage();

  final GetStorage _box;

  Future<void> write(String key, dynamic value) => _box.write(key, value);

  T? read<T>(String key) => _box.read<T>(key);

  Future<void> remove(String key) => _box.remove(key);

  Future<void> clear() => _box.erase();

  // Token helpers
  String? get accessToken => read<String>(StorageKeys.accessToken);

  Future<void> saveAccessToken(String token) =>
      write(StorageKeys.accessToken, token);

  Future<void> clearTokens() async {
    await remove(StorageKeys.accessToken);
    await remove(StorageKeys.refreshToken);
    await remove(StorageKeys.user);
  }

  bool get hasToken =>
      accessToken != null && accessToken!.trim().isNotEmpty;


  // Remember-me helpers (numéro de téléphone uniquement — jamais le mot de
  // passe, qui n'est jamais persisté côté client).
  String? get rememberedPhone => read<String>(StorageKeys.rememberedPhone);

  Future<void> saveRememberedPhone(String phone) =>
      write(StorageKeys.rememberedPhone, phone);

  Future<void> clearRememberedPhone() => remove(StorageKeys.rememberedPhone);
}
