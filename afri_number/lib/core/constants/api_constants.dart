import 'package:flutter/foundation.dart';

/// Constantes API configurables
class ApiConstants {
  ApiConstants._();

  /// URL de base de l'API - à configurer selon l'environnement
  /// En développement: utiliser l'IP locale de la machine (ex: 192.168.1.xxx)
  /// En production: utiliser l'URL de production
  static const String baseUrl = _defaultBaseUrl;

  /// URL par défaut - Remplacer par votre vraie URL d'API
  static const String _defaultBaseUrl = 'https://api.afrinumber.com/api';

  /// Pour le développement local, utilisez l'IP de votre machine sur le réseau local
  /// Exemple: 'http://192.168.1.100:3000/api' ou 'http://10.0.2.2:3000/api' (Android emulator)
  /// static const String baseUrl = 'http://192.168.1.XXX:3000/api';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  
  // OTP endpoints
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';
  
  // User endpoints
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile';

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