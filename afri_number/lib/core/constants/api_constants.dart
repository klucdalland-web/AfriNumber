class ApiConstants {
  ApiConstants._();

  /// Remplacer par l'URL de base de l'API AfriNumber.
  static const String baseUrl = 'https://api.afrinumber.local/api';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
}
