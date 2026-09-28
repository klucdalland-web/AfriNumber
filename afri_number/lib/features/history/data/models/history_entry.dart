enum HistoryKind {
  topUp,
  purchase,
  smsReceived,
  smsSent,
  callOutgoing,
  callIncoming,
}

/// Catégorie utilisée par les filtres de l'écran.
enum HistoryCategory { transactions, sms, calls }

/// Élément de l'historique : transaction, SMS ou appel.
class HistoryEntry {
  const HistoryEntry({
    required this.id,
    required this.kind,
    required this.title,
    required this.date,
    this.amount,
    this.counterpart,
    this.durationMinutes,
  });

  final String id;
  final HistoryKind kind;
  final String title;
  final DateTime date;

  /// Montant signé en MGA (positif = crédit, négatif = débit). Transactions.
  final int? amount;

  /// Numéro de l'interlocuteur (SMS).
  final String? counterpart;

  /// Durée en minutes (appels).
  final int? durationMinutes;

  HistoryCategory get category => switch (kind) {
        HistoryKind.topUp || HistoryKind.purchase => HistoryCategory.transactions,
        HistoryKind.smsReceived || HistoryKind.smsSent => HistoryCategory.sms,
        HistoryKind.callOutgoing || HistoryKind.callIncoming => HistoryCategory.calls,
      };
}

/// Entrées d'une même journée.
class HistoryGroup {
  const HistoryGroup({required this.label, required this.entries});

  final String label;
  final List<HistoryEntry> entries;
}
