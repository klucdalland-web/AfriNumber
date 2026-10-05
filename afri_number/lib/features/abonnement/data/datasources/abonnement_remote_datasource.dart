import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/device_info_service.dart';

class AbonnementRemoteDataSource {
  AbonnementRemoteDataSource(this._client, this._deviceInfo);

  final DioClient _client;
  final DeviceInfoService _deviceInfo;

  Future<List<dynamic>> fetchPlans() async {
    final deviceId = await _deviceInfo.getDeviceId();
    if (deviceId == null) {
      throw StateError(
        'No device ID is available to fetch subscription plans',
      );
    }

    final response = await _client.get(
      ApiConstants.abonnementPlans,
      options: Options(
        headers: {
          'x-api-key': ApiConstants.apiKey,
          'X-Device-Id': deviceId,
        },
      ),
    );
    final body = _responseData(response.data);
    final plans = body is Map ? body['plans'] : body;
    return plans is List ? plans : const [];
  }

  Future<Map<String, dynamic>> fetchCurrent() async {
    final response = await _client.get(ApiConstants.abonnementCurrent);
    final body = _responseData(response.data);
    if (body is! Map) return const {};
    final subscription = body['abonnement'] ?? body['subscription'];
    return subscription is Map
        ? Map<String, dynamic>.from(subscription)
        : Map<String, dynamic>.from(body);
  }

  Future<List<dynamic>> fetchHistory() async {
    final response = await _client.get(ApiConstants.abonnementsHistory);
    final body = _responseData(response.data);
    if (body is List) return body;
    if (body is Map) {
      final history =
          body['abonnements'] ??
          body['subscriptions'] ??
          body['items'] ??
          body['data'];
      if (history is List) return history;
    }
    return const [];
  }

  Future<Map<String, dynamic>> subscribe({
    required String planId,
    required String period,
    String? countryCode,
    String? operator,
    String? phone,
  }) async {
    final response = await _client.post(
      ApiConstants.abonnementSubscribe,
      data: {
        'plan_id': planId,
        'period': period,
        if (countryCode != null && operator != null && phone != null) ...{
          'payment_method': 'mobile_money',
          'country_code': countryCode,
          'operator': operator,
          'phone_number': phone,
        },
      },
    );
    final body = _responseData(response.data);
    return body is Map ? Map<String, dynamic>.from(body) : const {};
  }

  dynamic _responseData(dynamic response) =>
      response is Map ? response['data'] ?? response : response;
}
