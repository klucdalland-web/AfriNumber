import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/device_info_service.dart';
import '../../../../core/utils/storage_service.dart';

/// Source de données distante auth (API).
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client, this._storage, this._deviceInfo);

  final DioClient _client;
  final StorageService _storage;
  final DeviceInfoService _deviceInfo;

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

  Future<Map<String, dynamic>> verifyOtp({
    required String code,
    String? email,
  }) async {
    final response = await _client.post(
      '/auth/verify-otp',
      data: {'code': code, 'email': email},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> resendOtp({String? email}) async {
    final response = await _client.post(
      '/auth/resend-otp',
      data: {'email': email},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    final response = await _client.post(
      ApiConstants.forgotPassword,
      data: {'email': email},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final response = await _client.post(
      ApiConstants.resetPassword,
      data: {'email': email, 'code': code, 'password': newPassword},
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
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }

  Future<List<dynamic>> getCountries() async {
    final response = await _client.get('/pays');
    final body = response.data;
    final data = body is Map ? body['data'] : null;
    final list = data is Map ? data['pays'] : null;
    return (list as List?) ?? [];
  }
}
