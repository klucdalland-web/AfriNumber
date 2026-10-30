/// Forfait data proposé à l'achat.
class DataPlan {
  const DataPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.currency = 'MGA',
    this.period = 'mois',
  });

  final String id;
  final String name;
  final String description;
  final int price;
  final String currency;
  final String period;
}
