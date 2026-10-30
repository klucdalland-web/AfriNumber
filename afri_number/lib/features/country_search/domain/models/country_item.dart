/// Modèle de pays tel que retourné par l'API `/pays`.
///
/// Exemple de réponse API :
/// ```json
/// {
///   "id": 28,
///   "label": "Madagascar",
///   "code": "MG",
///   "indicatif": "+261",
///   "actif": true,
///   "organisation_id": 1,
///   "organisation": { "id": 1, "label": "AfriNumber", ... }
/// }
/// ```
class CountryItem {
  const CountryItem({
    required this.id,
    required this.name,
    required this.code,
    required this.dialCode,
    this.isActive = true,
    this.isPopular = false,
  });

  /// Identifiant unique (int de la BDD, ex. 28).
  final int id;

  /// Nom du pays (ex. "Madagascar").
  final String name;

  /// Code ISO à 2 lettres (ex. "MG"). Utilisé pour l'emoji drapeau.
  final String code;

  /// Indicatif téléphonique (ex. "+261").
  final String dialCode;

  /// `actif` depuis l'API.
  final bool isActive;

  /// Mis à `true` manuellement pour les pays mis en avant.
  final bool isPopular;

  /// Construit un [CountryItem] depuis un objet JSON unique du tableau `pays`.
  factory CountryItem.fromJson(Map<String, dynamic> json) {
    return CountryItem(
      id: (json['id'] as num).toInt(),
      name: json['label'] as String,
      code: (json['code'] as String).toUpperCase(),
      dialCode: json['indicatif'] as String? ?? '',
      isActive: json['actif'] as bool? ?? true,
    );
  }
}
