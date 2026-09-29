/// Formatage partagé (montants, heures, dates) — sans dépendance `intl`.
abstract class Formatters {
  /// `5000` → `5 000`.
  static String groupThousands(num value) {
    final digits = value.abs().round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  /// `5000` → `5 000 MGA`.
  static String amount(num value, {String currency = 'MGA'}) =>
      '${groupThousands(value)} $currency';

  /// `50000` → `+ 50 000 MGA`, `-15000` → `- 15 000 MGA`.
  static String signedAmount(num value, {String currency = 'MGA'}) {
    final sign = value >= 0 ? '+' : '-';
    return '$sign ${amount(value, currency: currency)}';
  }

  /// `14:32`.
  static String time(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

  static const _months = [
    'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
    'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
  ];

  /// `Aujourd'hui`, `Hier`, sinon `12 sept.` (ajoute l'année si différente).
  static String dayLabel(DateTime date, {DateTime? now}) {
    final today = _dayOnly(now ?? DateTime.now());
    final day = _dayOnly(date);
    final diff = today.difference(day).inDays;
    if (diff == 0) return "Aujourd'hui";
    if (diff == 1) return 'Hier';
    final base = '${day.day} ${_months[day.month - 1]}';
    return day.year == today.year ? base : '$base ${day.year}';
  }

  static DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
