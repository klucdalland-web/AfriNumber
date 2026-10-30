/// Ticket de vérification ouvert côté Laravel.
///
/// JSON attendu (`POST /verifier/init`) :
/// ```json
/// {
///   "statut": "autorise",
///   "profile_id": "01a10697-9c93-722c-9519-c4c24c579605",
///   "profile_status": "en_attente_d_upload",
///   "message": "Ticket de validation ouvert. ..."
/// }
/// ```
///
/// Si une demande est déjà en cours :
/// ```json
/// {
///   "statut": "refuse",
///   "profile_id": "...",
///   "profile_status": "en_cours_de_verification",
///   "erreur": "Une vérification est déjà en cours..."
/// }
/// ```
class KycProfile {
  /// Crée un profil de vérification.
  const KycProfile({
    required this.profileId,
    required this.status,
    required this.message,
    this.profileStatus,
  });

  /// Construit un [KycProfile] depuis un JSON.
  factory KycProfile.fromJson(Map<String, dynamic> json) {
    return KycProfile(
      profileId: (json['profile_id'] ?? '').toString(),
      status: (json['statut'] ?? '').toString(),
      message: (json['message'] ?? json['erreur'] ?? '').toString(),
      profileStatus: json['profile_status']?.toString(),
    );
  }

  /// Identifiant à transmettre à Express lors de l'upload.
  final String profileId;

  /// Statut renvoyé par Laravel (`autorise` / `refuse`).
  final String status;

  /// Message du serveur.
  final String message;

  /// Statut métier du dossier (`en_cours_de_verification`, `approuve`, …).
  final String? profileStatus;

  /// Le ticket est ouvert et exploitable pour un nouvel upload.
  bool get isAuthorized => status == 'autorise' && profileId.isNotEmpty;

  /// Laravel refuse un nouvel envoi car une demande est déjà ouverte.
  bool get isAlreadyPending {
    if (profileId.isEmpty) return false;
    final raw = (profileStatus ?? '').toLowerCase();
    return status == 'refuse' &&
        (raw == 'en_cours_de_verification' ||
            raw == 'validation_manuelle' ||
            raw == 'pending' ||
            raw == 'manual_review');
  }

  /// Compte déjà approuvé côté profil KYC.
  bool get isAlreadyApproved {
    if (profileId.isEmpty) return false;
    final raw = (profileStatus ?? '').toLowerCase();
    return status == 'refuse' &&
        (raw == 'approuve' || raw == 'approved' || raw == 'valide');
  }
}
