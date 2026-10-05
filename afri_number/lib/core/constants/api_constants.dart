import 'package:flutter/foundation.dart';

/// Constantes API configurables
class ApiConstants {
  ApiConstants._();

  /// URL de base de l'API - à configurer selon l'environnement
  /// En développement: utiliser l'IP locale de la machine (ex: 192.168.1.xxx)
  /// En production: utiliser l'URL de production
  static const String baseUrl = _defaultBaseUrl;
  // KYC
  /// Ouverture d'un ticket de vérification (Laravel).
  static const String kycInit = '/verifier/init';

  /// URL de base du service Express (upload de fichiers).
  static const String expressBaseUrl = 'http://localhost:3000';

  /// Upload multipart des documents (Express).
  static const String kycUpload = '/files/upload';

  /// Statut d'un dossier.
  static const String kycStatus = '/verifier/status';
  /// URL par défaut - Remplacer par votre vraie URL d'API
  static const String _defaultBaseUrl = 'https://afriserver.onrender.com/api/v1';
  static const String apiKey = 'Q4UqsMCrd6YIMWNb8JHUtlhiduidjdj';
  /// Pour le développement local, utilisez l'IP de votre machine sur le réseau local
  /// Exemple: 'http://192.168.1.100:3000/api' ou 'http://10.0.2.2:3000/api' (Android emulator)
  /// static const String baseUrl = 'http://192.168.1.XXX:3000/api';
// Abonnement endpoints
  static const String abonnementPlans = '/plans';
  static const String abonnementCurrent = '/abonnement';
  static const String abonnementsHistory = '/abonnements';
  static const String abonnementSubscribe = '/subscriptions/subscribe';

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // OTP endpoints
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';

  // À confirmer/adapter avec le backend : c'est le
  // seul endroit à changer si les vraies routes diffèrent.
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // User endpoints
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile';

  // Country endpoints
  /// Retourne la liste des pays disponibles sur la plateforme.
  static const String pays = '/pays';

  /// Vérifie si l'URL est configurée pour le développement local
  static bool get isLocalDevelopment {
    return baseUrl.contains('localhost') || 
           baseUrl.contains('127.0.0.1') || 
           baseUrl.contains('192.168.') ||
           baseUrl.contains('10.0.2.2');
  }

  /// Affiche l'URL de base en mode debug
  static void logBaseUrl() {
    if (kDebugMode) {
      print('API Base URL: $baseUrl');
      if (isLocalDevelopment) {
        print('⚠️ Mode développement local détecté');
      }
    }
  }
}
