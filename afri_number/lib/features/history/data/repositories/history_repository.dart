import '../models/history_entry.dart';

/// Contrat d'accès à l'historique.
///
/// Aucun endpoint backend n'est encore défini : le binding injecte
/// [MockHistoryRepository]. Brancher l'API = créer `HistoryRepositoryImpl`
/// et changer une ligne dans `HistoryBinding`.
abstract class HistoryRepository {
  Future<List<HistoryEntry>> fetchHistory();
}
