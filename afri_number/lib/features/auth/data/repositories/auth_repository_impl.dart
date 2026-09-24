import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../../../../core/utils/storage_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._storage);

  final AuthRemoteDataSource _remote;
  final StorageService _storage;

  @override
  Future<void> login({
    required String email,
    required String password,
  }) async {
    final result = await _remote.login(email: email, password: password);
    final token = result['token'] as String? ??
        (result['data'] is Map
            ? (result['data'] as Map)['token'] as String?
            : null);
    if (token != null) {
      await _storage.saveAccessToken(token);
    }
  }

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final result = await _remote.register(
      name: name,
      email: email,
      password: password,
    );
    final token = result['token'] as String? ??
        (result['data'] is Map
            ? (result['data'] as Map)['token'] as String?
            : null);
    if (token != null) {
      await _storage.saveAccessToken(token);
    }
  }

  @override
  Future<void> logout() => _remote.logout();

  @override
  Future<Map<String, dynamic>?> me() => _remote.me();
}
