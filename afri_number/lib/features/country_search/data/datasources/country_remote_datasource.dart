import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/models/country_item.dart';

/// Source de données distante pour la feature CountrySearch.
///
/// Appelle GET `/pays` et retourne une liste de [CountryItem].
///
/// Réponse attendue :
/// ```json
/// {
///   "success": true,
///   "data": {
///     "pays": [ { "id": 28, "label": "Madagascar", "code": "MG",
///                 "indicatif": "+261", "actif": true, ... } ],
///     "total": 1
///   }
/// }
/// ```
class CountryRemoteDataSource {
  const CountryRemoteDataSource(this._client);

  final DioClient _client;

  /// Récupère tous les pays actifs depuis l'API.
  /// Lance une [ApiException] en cas d'erreur réseau ou de réponse invalide.
  Future<List<CountryItem>> fetchCountries() async {
    final response = await _client.get<Map<String, dynamic>>(ApiConstants.pays);

    final body = response.data;
    if (body == null || body['success'] != true) {
      throw ApiException(
        statusCode: response.statusCode ?? 0,
        message: body?['message'] as String? ?? 'Erreur lors du chargement des pays.',
      );
    }

    // Extraction du tableau `data.pays`
    final data = body['data'] as Map<String, dynamic>?;
    final paysList = data?['pays'] as List<dynamic>? ?? [];

    return paysList
        .cast<Map<String, dynamic>>()
        .map(CountryItem.fromJson)
        .toList();
  }
}
