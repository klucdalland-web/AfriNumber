/// Pièce d'identité acceptée pour la vérification KYC.
///
/// JSON attendu :
/// ```json
/// {
///   "id": "id_card",
///   "label_key": "kyc.doc.id_card",
///   "icon": "id_card",
///   "requires_back": true
/// }
/// ```
class KycDocumentType {
  /// Crée un type de pièce.
  const KycDocumentType({
    required this.id,
    required this.labelKey,
    required this.icon,
    required this.requiresBack,
  });

  /// Construit un [KycDocumentType] depuis un JSON.
  factory KycDocumentType.fromJson(Map<String, dynamic> json) {
    return KycDocumentType(
      id: (json['id'] ?? '').toString(),
      labelKey: (json['label_key'] ?? '').toString(),
      icon: (json['icon'] ?? '').toString(),
      requiresBack: json['requires_back'] == true,
    );
  }

  /// Pièces acceptées (liste locale : l'API n'expose pas d'endpoint dédié).
  static const List<KycDocumentType> supported = <KycDocumentType>[
    KycDocumentType(
      id: 'id_card',
      labelKey: 'kyc.doc.id_card',
      icon: 'id_card',
      requiresBack: true,
    ),
    KycDocumentType(
      id: 'passport',
      labelKey: 'kyc.doc.passport',
      icon: 'passport',
      requiresBack: false,
    ),
    KycDocumentType(
      id: 'driver_license',
      labelKey: 'kyc.doc.driver_license',
      icon: 'driver_license',
      requiresBack: true,
    ),
  ];

  /// Identifiant unique (ex. `id_card`, `passport`).
  final String id;

  /// Clé i18n du libellé.
  final String labelKey;

  /// Clé d'icône (`id_card`, `passport`, `driver_license`).
  final String icon;

  /// Indique si le verso doit être capturé.
  final bool requiresBack;
}