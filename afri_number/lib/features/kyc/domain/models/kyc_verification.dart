/// Statut d'un dossier KYC soumis.
///
/// JSON attendu (endpoint de statut) :
/// ```json
/// { "statut": "en_cours_de_verification", "profile_id": "01a10697-..." }
/// ```
class KycVerification {
  /// Crée une vérification.
  const KycVerification({required this.status, required this.reference});

  /// Construit un [KycVerification] depuis un JSON (clés `status` ou `statut`).
  factory KycVerification.fromJson(Map<String, dynamic> json) {
    final String raw = (json['status'] ??
            json['statut'] ??
            json['profile_status'] ??
            '')
        .toString();
    return KycVerification(
      status: _normalize(raw),
      reference: (json['reference'] ?? json['profile_id'] ?? '').toString(),
    );
  }

  /// Statut normalisé (`pending`, `approved`, `rejected`, `awaiting_upload`, `none`).
  final String status;

  /// Référence du dossier (le `profile_id`).
  final String reference;

  /// Aucun dossier ouvert.
  bool get isNone => status == 'none';

  /// Ticket ouvert, documents pas encore (ou plus) uploadés — l'utilisateur peut renvoyer.
  bool get isAwaitingUpload => status == 'awaiting_upload';

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
      case 'aucun':
      case 'none':
      case '':
        return 'none';
      case 'en_attente_d_upload':
        return 'awaiting_upload';
      case 'manual_review':
      case 'en_cours_de_verification':
      case 'pending':
        return 'pending';
      default:
        return 'pending';
    }
  }
}
