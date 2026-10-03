/// Modèle représentant le profil de l'utilisateur connecté dans AfriNumber.
/// Correspond exactement aux structures JSON retournées par `/auth/user` et `/auth/me`.
class UserModel {
  const UserModel({
    this.name,
    this.email,
    this.phoneNumber,
    this.status,
    this.validationStatus,
    this.typeUser,
    this.country,
    this.organisation,
  });

  /// Nom de l'utilisateur ("nekena")
  final String? name;

  /// Adresse e-mail ("nekenaralisata@gmail.com")
  final String? email;

  /// Numéro de téléphone au format international ("+261387516861")
  final String? phoneNumber;

  /// Statut du compte ("actif", "inactif")
  final String? status;

  /// Statut de validation ("valide", "non_valide")
  final String? validationStatus;

  /// Informations du type d'utilisateur ({ "label": "Utilisateur", "code": "user", ... })
  final Map<String, dynamic>? typeUser;

  /// Informations du pays d'origine/résidence ({ "id": 28, "label": "Madagascar", "code": "MG", "indicatif": "+261", ... })
  final Map<String, dynamic>? country;

  /// Informations de l'organisation ({ "id": 1, "label": "AfriNumber", ... })
  final Map<String, dynamic>? organisation;

  /// Crée une instance de [UserModel] depuis une [Map] JSON.
  /// Gère automatiquement les structures avec `data.user`, `user`, ou les champs à la racine.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> userMap = json;

    // Extraction récursive si le JSON contient `data.user` ou `user`
    if (json.containsKey('data') && json['data'] is Map) {
      final dataMap = Map<String, dynamic>.from(json['data'] as Map);
      if (dataMap.containsKey('user') && dataMap['user'] is Map) {
        userMap = Map<String, dynamic>.from(dataMap['user'] as Map);
      } else {
        userMap = dataMap;
      }
    } else if (json.containsKey('user') && json['user'] is Map) {
      userMap = Map<String, dynamic>.from(json['user'] as Map);
    }

    return UserModel(
      name: userMap['name'] as String? ?? userMap['full_name'] as String?,
      email: userMap['email'] as String?,
      phoneNumber: userMap['phone_number'] as String? ?? userMap['phone'] as String?,
      status: userMap['statut'] as String? ?? userMap['status'] as String?,
      validationStatus: userMap['status_valide'] as String?,
      typeUser: _toMap(userMap['type_user']),
      country: _toMap(userMap['pays'] ?? userMap['country']),
      organisation: _toMap(userMap['organisation']),
    );
  }

  static Map<String, dynamic>? _toMap(Object? value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  /// Convertit le modèle en Map JSON pour la persistance locale dans [GetStorage].
  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone_number': phoneNumber,
        'statut': status,
        'status_valide': validationStatus,
        'type_user': typeUser,
        'pays': country,
        'organisation': organisation,
      };

  // ── Getters utilitaires pour l'affichage UI dans ProfileTab ──

  /// Nom complet affiché dans l'en-tête du profil
  String get fullName => name != null && name!.isNotEmpty ? name! : 'Membre AfriNumber';

  /// Pseudo généré depuis l'e-mail (ex: "@nekenaralisata")
  String get username => (email != null && email!.contains('@'))
      ? '@${email!.split('@').first}'
      : '@user';

  /// Libellé du type d'utilisateur (ex: "Utilisateur")
  String get userTypeLabel => typeUser?['label'] as String? ?? 'Utilisateur standard';

  /// Code du type d'utilisateur (ex: "user")
  String get userTypeCode => typeUser?['code'] as String? ?? 'user';

  /// Description du type d'utilisateur
  String get userTypeDescription => typeUser?['description'] as String? ?? '';

  /// Nom du pays (ex: "Madagascar")
  String get countryName => country?['label'] as String? ?? country?['name'] as String? ?? 'Madagascar';

  /// Code ISO du pays (ex: "MG")
  String get countryCode => (country?['code'] as String?)?.toUpperCase() ?? 'MG';

  /// Indicatif téléphonique du pays (ex: "+261")
  String get countryCallingCode => country?['indicatif'] as String? ?? '+261';

  /// ID du pays
  int? get countryId => country?['id'] is int ? country != null?['id'] as int : int.tryParse(country?['id']?.toString() ?? '') : null;

  /// Nom de l'organisation (ex: "AfriNumber")
  String get organisationName => organisation?['label'] as String? ?? 'AfriNumber';

  /// Indique si le compte est actif
  bool get isActive => status == 'actif' || status == 'active' || status == '1';

  /// Indique si le compte est validé
  bool get isValidated => validationStatus == 'valide' || validationStatus == 'true' || validationStatus == '1';

  /// Exemple statique pour les prévisualisations / chargement initial
  static const sample = UserModel(
    name: 'nekena',
    email: 'nekenaralisata@gmail.com',
    phoneNumber: '+261387516861',
    status: 'actif',
    validationStatus: 'non_valide',
    typeUser: {'label': 'Utilisateur', 'code': 'user', 'description': 'Utilisateur standard'},
    country: {'id': 28, 'label': 'Madagascar', 'code': 'MG', 'indicatif': '+261', 'actif': true},
    organisation: {'id': 1, 'label': 'AfriNumber', 'description': "Marchés d'expansion AfriNumber"},
  );

  @override
  String toString() {
    return 'UserModel(name: $name, email: $email, phone: $phoneNumber, status: $status, country: $countryName)';
  }
}

/// Alias de classe pour assurer la compatibilité ascendante du projet.
typedef UserProfile = UserModel;
