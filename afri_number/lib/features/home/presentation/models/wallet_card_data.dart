/// Modèle UI (temporaire) de la carte de solde.
/// À remplacer par une entité du domaine quand la couche Domain sera prête.
class WalletCardData {
  const WalletCardData({
    required this.currencyName,
    required this.currencySymbol,
    required this.balance,
    required this.virtualNumberMasked,
    required this.expiry,
    this.flagAsset,
  });

  final String currencyName;
  final String currencySymbol;
  final double balance;
  final String virtualNumberMasked;
  final String expiry;
  final String? flagAsset;

  /// Ex. « 12,289.98 » (milliers = virgule, décimales = point).
  String get formattedBalance {
    final parts = balance.toStringAsFixed(2).split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    return '$intPart.${parts[1]}';
  }
}
