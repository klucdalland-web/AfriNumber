import '../models/connectivity_overview.dart';

/// Contrat d'accès aux données de connectivité.
///
/// Aucun endpoint n'est encore défini côté backend pour cet écran : le
/// binding injecte [MockConnectivityRepository]. Pour brancher l'API,
/// créer `ConnectivityRepositoryImpl` (DioClient) et changer une seule ligne
/// dans `ConnectivityBinding`.
abstract class ConnectivityRepository {
  Future<ConnectivityOverview> fetchOverview();

  Future<void> setZeroData(bool enabled);
}
