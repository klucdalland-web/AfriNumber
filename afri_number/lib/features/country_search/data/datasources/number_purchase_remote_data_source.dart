import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/models/number_offer.dart';

class NumberPurchaseRemoteDataSource {
  NumberPurchaseRemoteDataSource(this._client);

  final DioClient _client;

  Future<List<NumberOffer>> searchAvailableNumbers(String countryCode) async {
    final response = await _client.dio.get<dynamic>(
      _endpoint('/numbers/search'),
      queryParameters: {'country': countryCode.toUpperCase()},
      options: Options(contentType: Headers.jsonContentType),
    );
    final body = response.data;
    if (body is Map && body['success'] == false) {
      throw StateError(body['message']?.toString() ?? 'Number search failed');
    }

    dynamic rows = body;
    if (body is Map) {
      rows = body['numbers'] ??
          body['phone_numbers'] ??
          body['available_numbers'] ??
          body['data'] ??
          body['results'];
    }
    if (rows is Map) {
      rows = rows['numbers'] ??
          rows['phone_numbers'] ??
          rows['available_numbers'] ??
          rows['data'] ??
          rows['results'];
    }
    if (rows is! List) return const [];

    return rows
        .whereType<Map>()
        .map((json) => NumberOffer.fromJson(Map<String, dynamic>.from(json)))
        .where((offer) => offer.phoneNumber.isNotEmpty)
        .toList();
  }

  Future<void> purchaseNumber({
    required String phoneNumber,
    required String countryCode,
  }) async {
    final response = await _client.dio.post<dynamic>(
      _endpoint('/numbers/buy'),
      data: {
        'phone_number': phoneNumber,
        'country': countryCode.toUpperCase(),
      },
    );
    if (response.data is Map && response.data['success'] == false) {
      throw StateError(
        response.data['message']?.toString() ?? 'Number purchase failed',
      );
    }
  }

  String _endpoint(String path) {
    final apiUri = Uri.parse(ApiConstants.baseUrl);
    final apiRootPath = apiUri.path.replaceFirst(RegExp(r'/v1/?$'), '');
    final routePath = '$apiRootPath$path';
    return apiUri.replace(path: routePath).toString();
  }
}
