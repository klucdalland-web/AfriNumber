/// Ticket de vérification ouvert côté Laravel.
///
/// JSON attendu (`POST /verifier/init`) :
/// ```json
/// {
///   "statut": "autorise",
///   "profile_id": "01a10697-9c93-722c-9519-c4c24c579605",
///   "message": "Ticket de validation ouvert. Veuillez transmettre cet ID à Express lors de l'upload."
/// }
/// ```
class KycProfile {
  /// Crée un profil de vérification.
  const KycProfile({
    required this.profileId,
    required this.status,
    required this.message,
  });

  /// Construit un [KycProfile] depuis un JSON.
  factory KycProfile.fromJson(Map<String, dynamic> json) {
    return KycProfile(
      profileId: (json['profile_id'] ?? '').toString(),
      status: (json['statut'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
    );
  }

  /// Identifiant à transmettre à Express lors de l'upload.
  final String profileId;

  /// Statut renvoyé par Laravel (`autorise` si le ticket est ouvert).
  final String status;

  /// Message du serveur.
  final String message;

  /// Le ticket est ouvert et exploitable.
  bool get isAuthorized => status == 'autorise' && profileId.isNotEmpty;
}