import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;

import '../../../app/routes/app_routes.dart';
import '../../constants/api_constants.dart';
import '../../utils/device_info_service.dart';
import '../../utils/storage_service.dart';

/// Ajoute le Bearer token et le renouvelle quand une requête reçoit un 401.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage, this._dio, this._deviceInfo)
    : _refreshDio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: ApiConstants.connectTimeout,
          receiveTimeout: ApiConstants.receiveTimeout,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'x-api-key': ApiConstants.apiKey,
          },
        ),
      );

  final StorageService _storage;
  final Dio _dio;
  final DeviceInfoService _deviceInfo;
  final Dio _refreshDio;

  Future<String?>? _refreshFuture;
  bool _sessionExpired = false;

  static const _retriedKey = 'auth_retry_after_refresh';

  static const _publicAuthPaths = {
    ApiConstants.login,
    ApiConstants.register,
    ApiConstants.verifyOtp,
    ApiConstants.resendOtp,
    ApiConstants.forgotPassword,
    ApiConstants.resetPassword,
    ApiConstants.refresh,
  };

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers['x-api-key'] = ApiConstants.apiKey;
    final token = _storage.accessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    final deviceId = await _deviceInfo.getDeviceId();
    if (deviceId != null) {
      options.headers['X-Device-Id'] = deviceId;
    }
    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final request = err.requestOptions;
    if (_isUnidentifiedDeviceError(err)) {
      await _expireSession();
      handler.next(err);
      return;
    }
    if (err.response?.statusCode != 401 ||
        request.extra[_retriedKey] == true ||
        _isPublicAuthRequest(request)) {
      handler.next(err);
      return;
    }

    try {
      final requestToken = _bearerToken(request.headers['Authorization']);
      final latestAccessToken = _storage.accessToken;
      // Another request may already have rotated the token while this 401 was
      // in flight. Reuse it instead of spending the refresh token again.
      final accessToken = latestAccessToken != null &&
              latestAccessToken != requestToken
          ? latestAccessToken
          : await (_refreshFuture ??= _refreshAccessToken()).whenComplete(() {
              _refreshFuture = null;
            });

      if (accessToken == null) {
        await _expireSession();
        handler.next(err);
        return;
      }

      request
        ..extra[_retriedKey] = true
        ..headers['Authorization'] = 'Bearer $accessToken';
      final response = await _dio.fetch<dynamic>(request);
      _sessionExpired = false;
      handler.resolve(response);
    } catch (error) {
      await _expireSession();
      if (error is DioException) {
        handler.next(error);
      } else {
        handler.next(err);
      }
    }
  }

  bool _isUnidentifiedDeviceError(DioException error) {
    if (error.response?.statusCode != 403) return false;
    final body = error.response?.data;
    final message = body is Map
        ? body['message']?.toString()
        : body?.toString();
    if (message == null) return false;
    final normalized = message.toLowerCase();
    return normalized.contains('appareil') &&
        (normalized.contains('identifi') || normalized.contains('reconnect'));
  }

  bool _isPublicAuthRequest(RequestOptions request) {
    final path = request.path.split('?').first;
    return _publicAuthPaths.any(
      (authPath) => path.endsWith(authPath),
    );
  }

  String? _bearerToken(dynamic authorization) {
    if (authorization is! String || !authorization.startsWith('Bearer ')) {
      return null;
    }
    return authorization.substring('Bearer '.length);
  }

  Future<String?> _refreshAccessToken() async {
    final refreshToken = _storage.refreshToken;
    if (refreshToken == null) return null;
    final deviceId = await _deviceInfo.getDeviceId();
    if (deviceId == null) {
      throw StateError('No device ID is available for token refresh');
    }

    final response = await _refreshDio.post<dynamic>(
      ApiConstants.refresh,
      data: {'refresh_token': refreshToken},
      options: Options(
        headers: {
          'x-api-key': ApiConstants.apiKey,
          'X-Device-Id': deviceId,
        },
      ),
    );
    final accessToken = _extractToken(response.data, {
      'access_token',
      'accessToken',
      'token',
      'bearer_token',
      'jwt',
      'auth_token',
    });
    if (accessToken == null) {
      throw const FormatException('Refresh response has no access token');
    }

    final rotatedRefreshToken = _extractToken(response.data, {
      'refresh_token',
      'refreshToken',
    });
    await _storage.saveAccessToken(accessToken);
    if (rotatedRefreshToken != null) {
      await _storage.saveRefreshToken(rotatedRefreshToken);
    }
    _sessionExpired = false;
    return accessToken;
  }

  String? _extractToken(dynamic json, Set<String> keys) {
    if (json is! Map) return null;
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) return value;
    }
    for (final key in [
      'data',
      'user',
      'authorization',
      'authorisation',
      'auth',
      'result',
    ]) {
      final value = _extractToken(json[key], keys);
      if (value != null) return value;
    }
    return null;
  }

  Future<void> _expireSession() async {
    if (_sessionExpired) return;
    _sessionExpired = true;
    try {
      await _storage.clearTokens();
    } catch (error) {
      debugPrint('[AuthInterceptor] Could not clear expired session: $error');
    }

    final currentRoute = Get.currentRoute;
    if (currentRoute != AppRoutes.login &&
        currentRoute != AppRoutes.welcome &&
        currentRoute != AppRoutes.register &&
        currentRoute != AppRoutes.otpVerification &&
        currentRoute != AppRoutes.authFeedbackConnexion &&
        currentRoute != AppRoutes.authFeedbackInscription) {
      Get.offAllNamed(AppRoutes.welcome);
    }
  }
}
