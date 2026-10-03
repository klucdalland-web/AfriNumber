enum BillingPeriod {
  monthly('Mensuel', 'mois'),
  annual('Annuel', 'an');

  const BillingPeriod(this.label, this.unit);

  final String label;
  final String unit;
}
