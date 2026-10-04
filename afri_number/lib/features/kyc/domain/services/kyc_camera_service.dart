import '../models/kyc_side.dart';

/// Erreur levée lorsque la caméra est inaccessible.
class KycCameraException implements Exception {
  /// Crée l'exception ; [denied] vaut `true` si la permission est refusée.
  const KycCameraException({this.denied = false});

  /// Indique un refus de permission caméra.
  final bool denied;
}

/// Contrat de capture photo (indépendant de tout package).
abstract class KycCameraService {
  /// Ouvre la caméra pour [side] et retourne le chemin du fichier,
  /// ou `null` si l'utilisateur annule.
  ///
  /// Lève [KycCameraException] si la caméra est inaccessible.
  Future<String?> capture(KycSide side);
}