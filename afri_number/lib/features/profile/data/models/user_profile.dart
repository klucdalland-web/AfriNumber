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

  final String? name;
  final String? email;
  final String? phoneNumber;
  final String? status;
  final String? validationStatus;
  final Map<String, dynamic>? typeUser;
  final Map<String, dynamic>? country;
  final Map<String, dynamic>? organisation;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final userMap = (json['data'] is Map && (json['data'] as Map).containsKey('user'))
        ? (json['data'] as Map)['user'] as Map<String, dynamic>
        : (json['data'] is Map ? Map<String, dynamic>.from(json['data'] as Map) : json);

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

  // Getters de commodité pour l'UI de l'onglet Profil
  String get fullName => name ?? 'Claudio Arthur';
  String get username => email != null && email!.isNotEmpty ? '@${email!.split('@').first}' : '@claudio_arthur_008';
  String get countryName => country?['name'] as String? ?? 'Madagascar';
  String get countryCode => country?['code'] as String? ?? 'MG';
  String get planName => typeUser?['name'] as String? ?? 'Offre Pro';
  int get activeNumbers => 3;
  int get countriesCount => 2;

  static const sample = UserModel(
    name: 'Claudio Arthur',
    email: 'claudio.arthur@example.com',
    phoneNumber: '+261 08 977 00',
    status: 'actif',
    validationStatus: 'valide',
  );

  @override
  String toString() {
    return 'UserModel(name: $name, email: $email, phone: $phoneNumber, status: $status)';
  }
}

typedef UserProfile = UserModel;
