import '../models/history_entry.dart';
import 'history_repository.dart';

/// Données de démonstration alignées sur la maquette (dates relatives à
/// aujourd'hui pour que « Aujourd'hui » / « Hier » restent corrects).
class MockHistoryRepository implements HistoryRepository {
  @override
  Future<List<HistoryEntry>> fetchHistory() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final now = DateTime.now();
    DateTime at(int daysAgo, int hour, int minute) =>
        DateTime(now.year, now.month, now.day - daysAgo, hour, minute);

    return [
      HistoryEntry(
        id: 'h1',
        kind: HistoryKind.topUp,
        title: 'Recharge MVola',
        date: at(0, 14, 32),
        amount: 50000,
      ),
      HistoryEntry(
        id: 'h2',
        kind: HistoryKind.smsReceived,
        title: 'SMS reçu',
        date: at(0, 13, 15),
        counterpart: '+1 555 0123',
      ),
      HistoryEntry(
        id: 'h3',
        kind: HistoryKind.purchase,
        title: 'Achat numéro US',
        date: at(0, 11, 45),
        amount: -15000,
      ),
      HistoryEntry(
        id: 'h4',
        kind: HistoryKind.smsSent,
        title: 'SMS envoyé',
        date: at(1, 20, 10),
        counterpart: '+261 34 123456',
      ),
      HistoryEntry(
        id: 'h5',
        kind: HistoryKind.callOutgoing,
        title: 'Appel sortant',
        date: at(1, 18, 30),
        durationMinutes: 12,
      ),
      HistoryEntry(
        id: 'h6',
        kind: HistoryKind.topUp,
        title: 'Recharge Airtel',
        date: at(1, 9, 0),
        amount: 20000,
      ),
    ];
  }
}
