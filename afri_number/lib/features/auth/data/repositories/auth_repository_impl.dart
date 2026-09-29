import 'package:dio/dio.dart';

import '../../../../core/errors/api_exception.dart';
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
    final result = await _request(
      () => _remote.login(email: email, password: password),
    );
    final token = _extractToken(result);
    if (token != null) {
      await _storage.saveAccessToken(token);
    }
  }

  @override
  Future<void> register({
    required String name,
    required String firstName,
    required String email,
    required String phoneNumber,
    required int countryId,
    required String password,
    required String passwordConfirmation,
  }) async {
    final result = await _request(
      () => _remote.register(
        name: name,
        firstName: firstName,
        email: email,
        phoneNumber: phoneNumber,
        countryId: countryId,
        password: password,
        passwordConfirmation: passwordConfirmation,
      ),
    );
    final token = _extractToken(result);
    if (token != null) {
      await _storage.saveAccessToken(token);
    }
  }

  @override
  Future<void> verifyOtp({
    required String code,
    String? email,
  }) async {
    final result = await _request(
      () => _remote.verifyOtp(code: code, email: email),
    );
    final token = _extractToken(result);
    if (token != null) {
      await _storage.saveAccessToken(token);
    }
  }

  @override
  Future<void> resendOtp({
    String? email,
  }) async {
    await _request(() => _remote.resendOtp(email: email));
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await _request(() => _remote.forgotPassword(email: email));
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await _request(
      () => _remote.resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
      ),
    );
  }

  @override
  Future<void> logout() async {
    try {
      await _remote.logout();
    } catch (_) {
      // Nettoie toujours les tokens même en cas d'échec réseau
    } finally {
      await _storage.clearTokens();
    }
  }

  @override
  Future<Map<String, dynamic>?> me() => _request(_remote.me);

  Future<T> _request<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (error) {
      if (error.error case final ApiException apiException) {
        throw apiException;
      }
      rethrow;
    }
  }

  String? _extractToken(Map<String, dynamic> result) {
    if (result['token'] is String && (result['token'] as String).isNotEmpty) {
      return result['token'] as String;
    }
    if (result['access_token'] is String && (result['access_token'] as String).isNotEmpty) {
      return result['access_token'] as String;
    }
    final data = result['data'];
    if (data is Map) {
      if (data['token'] is String && (data['token'] as String).isNotEmpty) {
        return data['token'] as String;
      }
      if (data['access_token'] is String && (data['access_token'] as String).isNotEmpty) {
        return data['access_token'] as String;
      }
    }
    final auth = result['authorisation'] ?? result['authorization'];
    if (auth is Map) {
      if (auth['token'] is String && (auth['token'] as String).isNotEmpty) {
        return auth['token'] as String;
      }
      if (auth['access_token'] is String && (auth['access_token'] as String).isNotEmpty) {
        return auth['access_token'] as String;
      }
    }
    return null;
  }
}

