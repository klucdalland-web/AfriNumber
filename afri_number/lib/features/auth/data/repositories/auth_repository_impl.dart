import 'package:afri_number/core/constants/country_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/utils/storage_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._storage);

  final AuthRemoteDataSource _remote;
  final StorageService _storage;

  @override
  Future<void> login({required String email, required String password}) async {
    final result = await _request(
      () => _remote.login(email: email, password: password),
    );
    if (kDebugMode) {
      print('=== Login API Raw Response ===');
      print(result);
    }
    final token = _extractToken(result);
    if (token != null) {
      if (kDebugMode) {
        print('=== Extracted Access Token ===');
        print(token);
      }
      await _storage.saveAccessToken(token);
    } else if (kDebugMode) {
      print('⚠️ Aucun token n\'a pu être extrait de la réponse login.');
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
  Future<void> verifyOtp({required String code, String? email}) async {
    final result = await _request(
      () => _remote.verifyOtp(code: code, email: email),
    );
    final token = _extractToken(result);
    if (token != null) {
      await _storage.saveAccessToken(token);
    }
  }

  @override
  Future<List<CountryData>> getCountries() async {
    final result = await _request(_remote.getCountries);
    return result
        .map((e) => CountryData.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<void> resendOtp({String? email}) async {
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

  /// Extraction récursive du token JWT/Bearer dans la réponse JSON backend
  /// (compatible avec token, access_token, bearer_token, data.token, authorization.token, etc.)
  String? _extractToken(dynamic json) {
    if (json == null) return null;

    if (json is String && json.isNotEmpty && json.length > 10) {
      return json;
    }

    if (json is Map) {
      // 1. Clés directes courantes
      for (final key in [
        'token',
        'access_token',
        'accessToken',
        'bearer_token',
        'jwt',
        'auth_token',
      ]) {
        final val = json[key];
        if (val is String && val.isNotEmpty) {
          return val;
        }
      }

      // 2. Recherche dans les objets imbriqués
      for (final key in [
        'data',
        'user',
        'authorization',
        'authorisation',
        'auth',
        'result',
      ]) {
        final child = json[key];
        final extracted = _extractToken(child);
        if (extracted != null) return extracted;
      }
    }

    return null;
  }
}
