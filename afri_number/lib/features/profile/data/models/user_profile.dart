/// Informations affichées dans l'onglet Profil.
class UserProfile {
  const UserProfile({
    required this.fullName,
    required this.username,
    required this.phoneNumber,
    required this.email,
    required this.countryName,
    required this.countryCode,
    required this.planName,
    required this.activeNumbers,
    required this.countriesCount,
  });

  /// Données d'exemple de la maquette (interface seule, sans backend).
  static const sample = UserProfile(
    fullName: 'Claudio Arthur',
    username: '@claudio_arthur_008',
    phoneNumber: '+261 08 977 00',
    email: 'claudio.arthur@example.com',
    countryName: 'Madagascar',
    countryCode: 'MG',
    planName: 'Basique',
    activeNumbers: 3,
    countriesCount: 2,
  );

  final String fullName;
  final String username;
  final String phoneNumber;
  final String email;
  final String countryName;

  /// Code ISO du pays (« MG », « FR »).
  final String countryCode;
  final String planName;
  final int activeNumbers;
  final int countriesCount;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final userMap = (json['data'] is Map && (json['data'] as Map).containsKey('user'))
        ? (json['data'] as Map)['user'] as Map<String, dynamic>
        : (json['data'] is Map ? Map<String, dynamic>.from(json['data'] as Map) : json);

    final firstName = userMap['first_name'] as String? ?? '';
    final lastName = userMap['name'] as String? ?? userMap['last_name'] as String? ?? '';
    final fullNameCombined = '$firstName $lastName'.trim();
    final emailStr = userMap['email'] as String? ?? 'user@afrinumber.com';

    return UserProfile(
      fullName: fullNameCombined.isNotEmpty
          ? fullNameCombined
          : (userMap['full_name'] as String? ?? 'Membre AfriNumber'),
      username: userMap['username'] as String? ??
          (userMap['user_name'] as String? ?? '@${emailStr.split('@').first}'),
      phoneNumber: userMap['phone_number'] as String? ??
          (userMap['phone'] as String? ?? '+261 34 00 000 00'),
      email: emailStr,
      countryName: userMap['country_name'] as String? ??
          (userMap['country'] is Map ? (userMap['country'] as Map)['name'] as String? : null) ??
          'Madagascar',
      countryCode: userMap['country_code'] as String? ??
          (userMap['country'] is Map ? (userMap['country'] as Map)['code'] as String? : null) ??
          'MG',
      planName: userMap['plan_name'] as String? ?? 'Offre Pro',
      activeNumbers: (userMap['active_numbers'] as num?)?.toInt() ?? 2,
      countriesCount: (userMap['countries_count'] as num?)?.toInt() ?? 4,
    );
  }

  Map<String, dynamic> toJson() => {
        'full_name': fullName,
        'username': username,
        'phone_number': phoneNumber,
        'email': email,
        'country_name': countryName,
        'country_code': countryCode,
        'plan_name': planName,
        'active_numbers': activeNumbers,
        'countries_count': countriesCount,
      };

  @override
  String toString() {
    return 'UserProfile(fullName: $fullName, username: $username, email: $email, phone: $phoneNumber, country: $countryName)';
  }
}
