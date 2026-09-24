import 'package:dio/dio.dart';

import '../../errors/api_exception.dart';

/// Transforme les erreurs Dio en [ApiException] structurées.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _mapException(err);
    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: exception,
        message: exception.message,
      ),
    );
  }

  ApiException _mapException(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Délai de connexion dépassé',
          statusCode: err.response?.statusCode,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          message: 'Pas de connexion internet',
          statusCode: err.response?.statusCode,
        );
      case DioExceptionType.badResponse:
        return _fromResponse(err.response);
      case DioExceptionType.cancel:
        return ApiException(message: 'Requête annulée');
      default:
        return ApiException(
          message: err.message ?? 'Une erreur est survenue',
          statusCode: err.response?.statusCode,
        );
    }
  }

  ApiException _fromResponse(Response? response) {
    final data = response?.data;
    String message = 'Erreur serveur';
    Map<String, dynamic>? errors;

    if (data is Map<String, dynamic>) {
      message = (data['message'] as String?) ?? message;
      errors = data['errors'] as Map<String, dynamic>?;
    }

    return ApiException(
      message: message,
      statusCode: response?.statusCode,
      errors: errors,
    );
  }
}
