/// Contrat du repository auth (domain).
abstract class AuthRepository {
  Future<void> login({required String email, required String password});

  Future<void> register({
    required String name,
    required String email,
    required String password,
  });

  Future<void> verifyOtp({
    required String code,
    String? email,
  });

  Future<void> resendOtp({
    String? email,
  });

  Future<void> logout();

  Future<Map<String, dynamic>?> me();
}