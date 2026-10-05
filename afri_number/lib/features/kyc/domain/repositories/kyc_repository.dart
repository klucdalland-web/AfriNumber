import '../models/kyc_document_type.dart';
import '../models/kyc_profile.dart';
import '../models/kyc_verification.dart';

/// Erreur métier du KYC, avec un éventuel message du serveur.
class KycException implements Exception {
  /// Crée l'exception ; [message] est le message serveur s'il existe.
  const KycException({this.message, this.messageKey});

  /// Message renvoyé par le serveur (déjà lisible), ou `null`.
  final String? message;

  /// Clé de traduction lorsqu'aucune réponse lisible n'est renvoyée.
  final String? messageKey;
}

/// Contrat d'accès aux données KYC.
abstract class KycRepository {
  /// Retourne les pièces d'identité acceptées.
  Future<List<KycDocumentType>> getDocumentTypes();

  /// Ouvre un ticket de vérification et retourne le profil créé.
  ///
  /// Lève [KycException] si le serveur n'autorise pas la vérification.
  Future<KycProfile> initVerification();

  /// Envoie les documents du dossier [profileId] en un seul appel.
  ///
  /// [backPath] est omis pour les pièces sans verso (passeport).
  Future<void> uploadDocuments({
    required String profileId,
    required String selfiePath,
    required String frontPath,
    String? backPath,
  });

  /// Retourne le statut courant du dossier [profileId].
  Future<KycVerification> getVerificationStatus({required String profileId});
}
