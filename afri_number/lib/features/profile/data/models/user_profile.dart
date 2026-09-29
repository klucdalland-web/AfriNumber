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
}
