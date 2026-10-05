import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/models/kyc_profile.dart';
import '../../domain/models/kyc_verification.dart';
import '../../domain/repositories/kyc_repository.dart';

/// Source de données distante du KYC : Laravel (init, statut) et Express (upload).
class KycRemoteDataSource {
  /// Crée la source avec le [DioClient] partagé (Laravel).
  ///
  /// Un [Dio] Express peut être injecté pour les tests ; par défaut il est
  /// créé sans token ni clé API (service interne).
  KycRemoteDataSource(this._client, {Dio? expressDio})
    : _express =
          expressDio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConstants.expressBaseUrl,
              connectTimeout: const Duration(seconds: 15),
              sendTimeout: const Duration(seconds: 60),
              receiveTimeout: const Duration(seconds: 60),
            ),
          );

  final DioClient _client;
  final Dio _express;

  /// POST `/verifier/init` : `{ statut, profile_id, message }`.
  /// POST `/verifier/init` : `{ statut, profile_id, message }`.
  Future<KycProfile> initVerification() async {
    final res = await _laravel(
      () => _client.post<Map<String, dynamic>>(ApiConstants.kycInit),
    );
    return KycProfile.fromJson(res.data ?? <String, dynamic>{});
  }

  Future<Response<T>> _laravel<T>(Future<Response<T>> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      final Object? inner = e.error;
      if (inner is ApiException) throw inner;
      throw KycException(message: _serverMessage(e));
    }
  }

  String? _serverMessage(DioException e) {
    final dynamic body = e.response?.data;
    if (body is! Map) return null;
    final dynamic message = body['message'] ?? body['erreur'] ?? body['error'];
    return message?.toString();
  }

  /// POST multipart `/files/upload` vers Express (réponse 201).
  ///
  /// Champs : `idprofile`, `photopath`, `pieceavantpath`, `piecearrierepath`.
  /// Lève [KycException] en cas d'échec réseau ou serveur.
  Future<void> uploadDocuments({
    required String profileId,
    required String selfiePath,
    required String frontPath,
    String? backPath,
  }) async {
    try {
      final FormData form = FormData.fromMap(<String, dynamic>{
        'idprofile': profileId,
        'photopath': await _file(selfiePath),
        'pieceavantpath': await _file(frontPath),
        if (backPath != null) 'piecearrierepath': await _file(backPath),
      });
      final response = await _express.post<Map<String, dynamic>>(
        ApiConstants.kycUpload,
        data: form,
      );
      if (kDebugMode) {
        debugPrint(
          '[KycRemoteDataSource] Express upload accepted: '
          'status=${response.statusCode}, url=${response.requestOptions.uri}',
        );
      }
    } on DioException catch (e) {
      final uri = e.requestOptions.uri;
      if (kDebugMode) {
        debugPrint(
          '[KycRemoteDataSource] Express upload failed: '
          'url=${uri.origin}${uri.path}, type=${e.type}, '
          'status=${e.response?.statusCode}',
        );
      }
      throw KycException(
        message: _serverMessage(e),
        messageKey: _expressErrorMessageKey(e),
      );
    }
  }

  String? _expressErrorMessageKey(DioException error) {
    if (error.response != null) return null;
    return switch (error.type) {
      DioExceptionType.connectionError ||
      DioExceptionType.connectionTimeout => 'kyc.express.unreachable',
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => 'kyc.express.timeout',
      _ => 'kyc.err',
    };
  }

  /// GET du statut (endpoint à confirmer).
  Future<KycVerification> fetchStatus({required String profileId}) async {
    final res = await _laravel(
      () => _client.get<Map<String, dynamic>>(
        '${ApiConstants.kycStatus}/$profileId',
      ),
    );
    final Map<String, dynamic> body = res.data ?? <String, dynamic>{};
    final dynamic inner = body['data'];
    final Map<String, dynamic> json = inner is Map<String, dynamic>
        ? inner
        : body;
    return KycVerification.fromJson(<String, dynamic>{
      ...json,
      'reference': profileId,
    });
  }

  Future<MultipartFile> _file(String path) {
    return MultipartFile.fromFile(path, contentType: _mediaTypeOf(path));
  }

  /// Express filtre sur jpg, png, webp et heic : on précise le type MIME.
  DioMediaType _mediaTypeOf(String path) {
    switch (path.split('.').last.toLowerCase()) {
      case 'png':
        return DioMediaType('image', 'png');
      case 'webp':
        return DioMediaType('image', 'webp');
      case 'heic':
        return DioMediaType('image', 'heic');
      default:
        return DioMediaType('image', 'jpeg');
    }
  }
}
