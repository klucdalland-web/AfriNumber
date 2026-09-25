import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/errors/api_exception.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthController extends GetxController {
  AuthController(this._repository);

  final AuthRepository _repository;

  final isLoading = false.obs;
  final formKey = GlobalKey<FormState>();

  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  // Register controllers
  final lastNameController = TextEditingController();
  final firstNameController = TextEditingController();
  final emailController = TextEditingController();
  final registerPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // OTP controller
  final otpController = TextEditingController();

  // Error message
  final errorMessage = ''.obs;

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    lastNameController.dispose();
    firstNameController.dispose();
    emailController.dispose();
    registerPasswordController.dispose();
    confirmPasswordController.dispose();
    otpController.dispose();
    super.onClose();
  }

  /// Clear error message
  void clearError() => errorMessage.value = '';

  /// Login with email/phone and password
  Future<bool> login() async {
    clearError();
    isLoading.value = true;

    try {
      final email = phoneController.text.trim();
      final password = passwordController.text;

      if (email.isEmpty || password.isEmpty) {
        errorMessage.value = 'Email/téléphone et mot de passe requis';
        isLoading.value = false;
        return false;
      }

      await _repository.login(email: email, password: password);

      // Fetch user profile after login
      await _fetchUserProfile();

      isLoading.value = false;
      return true;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      isLoading.value = false;
      return false;
    } catch (e) {
      errorMessage.value =
          'Erreur de connexion. Vérifiez votre connexion internet.';
      isLoading.value = false;
      return false;
    }
  }

  /// Register new user
  Future<bool> register() async {
    clearError();
    isLoading.value = true;

    try {
      final name =
          '${lastNameController.text.trim()} ${firstNameController.text.trim()}';
      final email = emailController.text.trim();
      final password = registerPasswordController.text;

      if (name.trim().isEmpty || email.isEmpty || password.isEmpty) {
        errorMessage.value = 'Tous les champs sont requis';
        isLoading.value = false;
        return false;
      }

      if (password != confirmPasswordController.text) {
        errorMessage.value = 'Les mots de passe ne correspondent pas';
        isLoading.value = false;
        return false;
      }

      if (password.length < 8) {
        errorMessage.value =
            'Le mot de passe doit contenir au moins 8 caractères';
        isLoading.value = false;
        return false;
      }

      await _repository.register(name: name, email: email, password: password);

      isLoading.value = false;
      return true;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      isLoading.value = false;
      return false;
    } catch (e) {
      errorMessage.value =
          'Erreur lors de l\'inscription. Veuillez réessayer.';
      isLoading.value = false;
      return false;
    }
  }

  /// Verify OTP code
  Future<bool> verifyOtp() async {
    clearError();
    isLoading.value = true;

    try {
      final code = otpController.text.trim();

      if (code.length != 4) {
        errorMessage.value = 'Le code doit contenir 4 chiffres';
        isLoading.value = false;
        return false;
      }

      final email = emailController.text.trim();
      await _repository.verifyOtp(code: code, email: email.isNotEmpty ? email : null);

      isLoading.value = false;
      return true;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      isLoading.value = false;
      return false;
    } catch (e) {
      errorMessage.value = 'Code invalide. Veuillez réessayer.';
      isLoading.value = false;
      return false;
    }
  }

  /// Resend OTP code
  Future<void> resendOtp() async {
    clearError();
    try {
      final email = emailController.text.trim();
      await _repository.resendOtp(email: email.isNotEmpty ? email : null);
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Erreur lors du renvoi du code';
    }
  }

  /// Fetch user profile after login
  Future<void> _fetchUserProfile() async {
    try {
      await _repository.me();
    } catch (e) {
      // Ignore profile fetch errors
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _repository.logout();
    } catch (e) {
      // Ignore logout errors
    }
  }

  /// Navigate based on login/register success
  void navigateAfterAuth(bool isRegister) {
    if (isRegister) {
      Get.offAllNamed('/otp-verification');
    } else {
      Get.offAllNamed('/dashboard');
    }
  }
}