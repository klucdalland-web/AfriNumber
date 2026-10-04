import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';

class AbonnementRemoteDataSource {
  AbonnementRemoteDataSource(this._client);

  final DioClient _client;

  Future<List<dynamic>> fetchPlans() async {
    final response = await _client.get(ApiConstants.abonnementPlans);
    final data = response.data;
    final body = data is Map ? data['data'] ?? data : data;
    return body is List ? body : const [];
  }

  Future<Map<String, dynamic>> fetchCurrent() async {
    final response = await _client.get(ApiConstants.abonnementCurrent);
    final data = response.data;
    final body = data is Map ? data['data'] ?? data : data;
    return body is Map ? Map<String, dynamic>.from(body) : const {};
  }

  Future<Map<String, dynamic>> subscribe({
    required String planId,
    required String period,
  }) async {
    final response = await _client.post(
      ApiConstants.abonnementSubscribe,
      data: {
        'plan_id': planId,
        'period': period,
      },
    );
    final data = response.data;
    final body = data is Map ? data['data'] ?? data : data;
    return body is Map ? Map<String, dynamic>.from(body) : const {};
  }
}
