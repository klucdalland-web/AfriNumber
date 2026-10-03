import 'package:afri_number/core/constants/country_constants.dart';

/// Contrat du repository auth (domain).
abstract class AuthRepository {
  Future<void> login({required String email, required String password});

  Future<void> register({
    required String name,
    required String firstName,
    required String email,
    required String phoneNumber,
    required int countryId,
    required String password,
    required String passwordConfirmation,
  });

  Future<void> verifyOtp({required String code, String? email});

  Future<void> resendOtp({String? email});

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
