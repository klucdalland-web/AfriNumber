import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/storage_service.dart';

/// Source de données distante auth (API).
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client, this._storage);

  final DioClient _client;
  final StorageService _storage;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      ApiConstants.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
      },
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<void> logout() async {
    await _client.post(ApiConstants.logout);
    await _storage.clearTokens();
  }

  Future<Map<String, dynamic>?> me() async {
    final response = await _client.get(ApiConstants.me);
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    return null;
  }
}
