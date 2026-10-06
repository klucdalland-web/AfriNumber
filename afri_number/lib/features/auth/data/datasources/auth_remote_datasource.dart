import 'package:flutter/foundation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/device_info_service.dart';
import '../../../../core/utils/storage_service.dart';

/// Source de données distante pour le module Authentification.
/// Communique avec le backend HTTP via [DioClient].
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client, this._storage, this._deviceInfo);

  final DioClient _client;
  final StorageService _storage;
  final DeviceInfoService _deviceInfo;

  /// Exécute l'appel API de connexion (POST /auth/login).
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final device = await _deviceInfo.collect();
    final response = await _client.post(
      ApiConstants.login,
      data: {'email': email, 'password': password, ...device},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// Exécute l'appel API d'inscription (POST /auth/register).
  Future<Map<String, dynamic>> register({
    required String name,
    required String firstName,
    required String email,
    required String phoneNumber,
    required int countryId,
    required String password,
    required String passwordConfirmation,
  }) async {
    final device = await _deviceInfo.collect();
    final response = await _client.post(
      ApiConstants.register,
      data: {
        'contrie_id': countryId,
        'name': name,
        'first_name': firstName,
        'email': email,
        'phone_number': phoneNumber,
        'password': password,
        'password_confirmation': passwordConfirmation,
        ...device,
      },
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

// Vérification du code OTP
  Future<Map<String, dynamic>> verifyOtp({
    required String code,
    required String purpose,
    String? email,
    String? phoneNumber,
  }) async {
    final response = await _client.post(
      ApiConstants.verifyOtp,
      data: {
        if (email != null && email.isNotEmpty) 'email': email,
        if (phoneNumber != null && phoneNumber.isNotEmpty)
          'phone_number': phoneNumber,
        'purpose': purpose,
        'code': code,
      },
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  // Renvoi du code OTP
  Future<Map<String, dynamic>> resendOtp({
    required String purpose,
    String? email,
    String? phoneNumber,
  }) async {
    final response = await _client.post(
      ApiConstants.resendOtp,
      data: {
        if (email != null && email.isNotEmpty) 'email': email,
        if (phoneNumber != null && phoneNumber.isNotEmpty)
          'phone_number': phoneNumber,
        'purpose': purpose,
      },
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// Demande de réinitialisation de mot de passe (POST /auth/forgot-password).
  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    final response = await _client.post(
      ApiConstants.forgotPassword,
      data: {'email': email},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// Réinitialise le mot de passe avec le code (POST /auth/reset-password).
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
    required String passwordConfirmation,
  }) async {
    final response = await _client.post(
      ApiConstants.resetPassword,
      data: {
        'email': email,
        'code': code,
        'password': newPassword,
<<<<<<< HEAD
        'password_confirmation': newPassword,
=======
        'password_confirmation': passwordConfirmation,
>>>>>>> e04c6dc427fe99aea3bc65f23f8ae82d007e5651
      },
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// Déconnecte l'utilisateur côté serveur (POST /auth/logout).
  Future<void> logout() async {
    await _client.post(ApiConstants.logout);
    await _storage.clearTokens();
  }

  /// Récupère le profil de l'utilisateur actuellement connecté depuis l'API.
  /// Interroge l'endpoint `/auth/user` (ou `/auth/me` selon la constante [ApiConstants.me]).
  ///
  /// Format de réponse backend géré :
  /// ```json
  /// {
  ///   "success": true,
  ///   "data": {
  ///     "user": {
  ///       "name": "nekena",
  ///       "email": "nekenaralisata@gmail.com",
  ///       "phone_number": "+261387516861",
  ///       "statut": "actif",
  ///       "status_valide": "non_valide",
  ///       "type_user": { "label": "Utilisateur", "code": "user" },
  ///       "pays": { "id": 28, "label": "Madagascar", "code": "MG", "indicatif": "+261" },
  ///       "organisation": { "id": 1, "label": "AfriNumber" }
  ///     }
  ///   }
  /// }
  /// ```
  Future<Map<String, dynamic>?> me() async {
    try {
      final response = await _client.get(ApiConstants.me);
      final rawData = response.data;
      if (rawData is! Map) return null;

      final map = Map<String, dynamic>.from(rawData);

      // 1. Déballage du noeud `data.user` conformément au format backend officiel
      if (map['data'] is Map) {
        final dataMap = Map<String, dynamic>.from(map['data'] as Map);
        if (dataMap['user'] is Map) {
          return Map<String, dynamic>.from(dataMap['user'] as Map);
        }
        return dataMap;
      }

      // 2. Déballage alternatif si le noeud `user` est directement à la racine
      if (map['user'] is Map) {
        return Map<String, dynamic>.from(map['user'] as Map);
      }

      // 3. Fallback si les champs utilisateur sont directement à la racine
      return map;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[AuthRemoteDataSource] Erreur lors de la récupération du profil utilisateur: $e',
        );
      }
      rethrow;
    }
  }

  Future<List<dynamic>> getCountries() async {
    final response = await _client.get('/pays');
    final body = response.data;
    final data = body is Map ? body['data'] : null;
    final list = data is Map ? data['pays'] : null;
    return (list as List?) ?? [];
  }
}
