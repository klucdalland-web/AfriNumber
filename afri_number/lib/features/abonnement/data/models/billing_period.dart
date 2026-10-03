/// Période de facturation disponible pour les abonnements.
///
/// Chaque valeur expose une [labelKey] et une [unitKey] qui sont
/// des clés GetX. Appelez `.labelKey.tr` et `.unitKey.tr` dans les widgets
/// pour obtenir le texte dans la langue active.
enum BillingPeriod {
  monthly('abonnement.period_monthly', 'abonnement.unit_month'),
  annual('abonnement.period_annual', 'abonnement.unit_year');

  const BillingPeriod(this.labelKey, this.unitKey);

  /// Clé GetX pour le libellé de la période (ex. "Mensuel" / "Monthly").
  final String labelKey;

  /// Clé GetX pour l'unité de temps (ex. "mois" / "month").
  final String unitKey;
}
