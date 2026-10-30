import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';

/// Source de données distante Profil (API) suivant le même modèle que AuthRemoteDataSource.
class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._client);

  final DioClient _client;

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _client.get(ApiConstants.me);
    return Map<String, dynamic>.from(response.data as Map);
  }
}
