import 'history_entry.dart';

/// Filtres de l'onglet Historique (Tout / Transactions / SMS / Appels).
enum HistoryFilter {
  all('Tout'),
  transactions('Transactions'),
  sms('SMS'),
  calls('Appels');

  const HistoryFilter(this.label);

  final String label;

  bool matches(HistoryEntry entry) => switch (this) {
        HistoryFilter.all => true,
        HistoryFilter.transactions => entry.category == HistoryCategory.transactions,
        HistoryFilter.sms => entry.category == HistoryCategory.sms,
        HistoryFilter.calls => entry.category == HistoryCategory.calls,
      };
}
