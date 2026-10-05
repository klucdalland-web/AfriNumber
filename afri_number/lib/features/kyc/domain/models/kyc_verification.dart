/// Statut d'un dossier KYC soumis.
///
/// JSON attendu (endpoint de statut, à confirmer) :
/// ```json
/// { "statut": "en_attente", "reference": "01a10697-..." }
/// ```
class KycVerification {
  /// Crée une vérification.
  const KycVerification({required this.status, required this.reference});

  /// Construit un [KycVerification] depuis un JSON (clés `status` ou `statut`).
  factory KycVerification.fromJson(Map<String, dynamic> json) {
    final String raw = (json['status'] ?? json['statut'] ?? '').toString();
    return KycVerification(
      status: _normalize(raw),
      reference: (json['reference'] ?? json['profile_id'] ?? '').toString(),
    );
  }

  /// Statut normalisé (`pending`, `approved`, `rejected`).
  final String status;

  /// Référence du dossier (le `profile_id`).
  final String reference;

  /// Le dossier est en cours d'examen.
  bool get isPending => status == 'pending';

  /// Le dossier est validé.
  bool get isApproved => status == 'approved';

  /// Le dossier est refusé.
  bool get isRejected => status == 'rejected';

  static String _normalize(String raw) {
    switch (raw.toLowerCase()) {
      case 'approved':
      case 'verified':
      case 'approuve':
      case 'valide':
      case 'validé':
      case 'verifie':
      case 'vérifié':
        return 'approved';
      case 'rejected':
      case 'rejete':
      case 'rejeté':
      case 'refuse':
      case 'refusé':
        return 'rejected';
      case 'manual_review':
      case 'en_cours_de_verification':
      case 'en_attente_d_upload':
      case 'pending':
        return 'pending';
      default:
        return 'pending';
    }
  }
}
