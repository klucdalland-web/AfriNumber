import 'package:afri_number/core/constants/country_constants.dart';
import 'package:dio/dio.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/utils/storage_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._storage);

  final AuthRemoteDataSource _remote;
  final StorageService _storage;

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final result = await _request(
      () => _remote.login(email: email, password: password),
    );

    return result;
  }

  @override
  Future<Map<String, dynamic>> register({
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
    return result;
  }

  @override
  Future<Map<String, dynamic>> resendOtp({
    required String purpose,
    String? email,
  }) {
    return _request(() => _remote.resendOtp(email: email, purpose: purpose));
  }

  @override
  Future<Map<String, dynamic>> verifyOtp({
    required String code,
    String? email,
    required String purpose,
  }) async {
    final result = await _request(
      () => _remote.verifyOtp(code: code, email: email, purpose: purpose),
    );
    final accessToken = _extractValue(result, {
      'access_token',
      'accessToken',
      'token',
      'bearer_token',
      'jwt',
      'auth_token',
    });
    final refreshToken = _extractValue(result, {
      'refresh_token',
      'refreshToken',
    });
    if (accessToken != null) await _storage.saveAccessToken(accessToken);
    if (refreshToken != null) await _storage.saveRefreshToken(refreshToken);
    return result;
  }

  @override
  Future<List<CountryData>> getCountries() async {
    final result = await _request(_remote.getCountries);
    return result
        .map((e) => CountryData.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
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

  String? _extractValue(dynamic json, Set<String> keys) {
    if (json is! Map) return null;
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.isNotEmpty) return value;
    }
    for (final key in [
      'data',
      'user',
      'authorization',
      'authorisation',
      'auth',
      'result',
    ]) {
      final value = _extractValue(json[key], keys);
      if (value != null) return value;
    }
    return null;
  }
}
