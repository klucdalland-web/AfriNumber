enum AbonnementCheckoutStatus { success, requiresAction, failed }

class AbonnementCheckoutResult {
  const AbonnementCheckoutResult({
    required this.status,
    this.checkoutUrl,
    this.message,
  });

  final AbonnementCheckoutStatus status;
  final String? checkoutUrl;
  final String? message;
}
