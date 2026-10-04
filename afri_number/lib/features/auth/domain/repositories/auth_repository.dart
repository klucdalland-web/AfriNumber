import 'package:afri_number/core/constants/country_constants.dart';

/// Contrat du repository auth (domain).
abstract class AuthRepository {
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  });

  Future<Map<String, dynamic>> register({
    required String name,
    required String firstName,
    required String email,
    required String phoneNumber,
    required int countryId,
    required String password,
    required String passwordConfirmation,
  });

  Future<Map<String, dynamic>> verifyOtp({
    required String code,
    required String purpose,
    String? email,
  });

  Future<Map<String, dynamic>> resendOtp({
    required String purpose,
    String? email,
  });

  Future<void> forgotPassword({required String email});

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });

  Future<List<CountryData>> getCountries();

  Future<void> logout();

  Future<Map<String, dynamic>?> me();
}
