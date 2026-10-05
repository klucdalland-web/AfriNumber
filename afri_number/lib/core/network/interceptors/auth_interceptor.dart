import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;

import '../../../app/routes/app_routes.dart';
import '../../utils/storage_service.dart';

/// Ajoute le Bearer token et gère le 401 (redirection login).
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage);

  final StorageService _storage;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _storage.accessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _storage.clearTokens().catchError((Object error) {
        debugPrint('[AuthInterceptor] Could not clear expired session: $error');
      });
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
    handler.next(err);
  }
}
