import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/utils/storage_service.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthController extends GetxController {
  AuthController(this._repository, this._storage);

  final AuthRepository _repository;
  final StorageService _storage;

  final isLoading = false.obs;
  final rememberMe = false.obs;

  final loginFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();
  final forgotPasswordFormKey = GlobalKey<FormState>();
  final resetPasswordFormKey = GlobalKey<FormState>();

  // Login controllers
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  // Register controllers
  final lastNameController = TextEditingController();
  final firstNameController = TextEditingController();
  final emailController = TextEditingController();
  final registerPhoneController = TextEditingController();
  final registerPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final int _defaultCountryId = 1;

  // OTP controller
  final otpController = TextEditingController();

  // Forgot / reset password controllers
  final forgotPasswordEmailController = TextEditingController();
  final resetCodeController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();

  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final remembered = _storage.rememberedPhone;
    if (remembered != null && remembered.isNotEmpty) {
      phoneController.text = remembered;
      rememberMe.value = true;
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    lastNameController.dispose();
    firstNameController.dispose();
    emailController.dispose();
    registerPhoneController.dispose();
    registerPasswordController.dispose();
    confirmPasswordController.dispose();
    otpController.dispose();
    forgotPasswordEmailController.dispose();
    resetCodeController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.onClose();
  }

  void clearError() => errorMessage.value = '';

  void toggleRememberMe(bool value) => rememberMe.value = value;

  Future<void> login() async {
    if (!(loginFormKey.currentState?.validate() ?? false)) return;

    clearError();
    isLoading.value = true;

    try {
      // Garantit l'envoi de la chaîne complète saisie sans espaces parasites
      final identifier = phoneController.text.trim();
      final password = passwordController.text;

      await _repository.login(email: identifier, password: password);

      await _fetchUserProfile();

      if (rememberMe.value) {
        await _storage.saveRememberedPhone(identifier);
      } else {
        await _storage.clearRememberedPhone();
      }

      isLoading.value = false;
      Get.offAllNamed(AppRoutes.authFeedbackConnexion);
    } on ApiException catch (e) {
      isLoading.value = false;
      errorMessage.value = e.message;
    } catch (_) {
      isLoading.value = false;
      errorMessage.value = 'Erreur de connexion. Veuillez réessayer.';
    }
  }

  Future<void> register() async {
    if (!(registerFormKey.currentState?.validate() ?? false)) return;

    clearError();
    isLoading.value = true;

    try {
      final name = lastNameController.text.trim();
      final firstName = firstNameController.text.trim();
      final email = emailController.text.trim();
      final phoneNumber = registerPhoneController.text.trim();
      final password = registerPasswordController.text;
      final passwordConfirmation = confirmPasswordController.text;

      await _repository.register(
        name: name,
        firstName: firstName,
        email: email,
        phoneNumber: phoneNumber,
        countryId: _defaultCountryId,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      isLoading.value = false;
      Get.offAllNamed(AppRoutes.otpVerification);
    } on ApiException catch (e) {
      isLoading.value = false;
      errorMessage.value = e.message;
    } catch (_) {
      isLoading.value = false;
      errorMessage.value = 'Erreur lors de l\'inscription. Veuillez réessayer.';
    }
  }

  Future<void> verifyOtp() async {
    clearError();
    isLoading.value = true;

    try {
      final code = otpController.text.trim();

      if (code.length != 4) {
        errorMessage.value = 'Le code doit contenir 4 chiffres';
        isLoading.value = false;
        return;
      }

      final email = emailController.text.trim();
      await _repository.verifyOtp(code: code, email: email.isNotEmpty ? email : null);

      isLoading.value = false;
      Get.offAllNamed(AppRoutes.authFeedbackInscription);
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      isLoading.value = false;
    } catch (_) {
      errorMessage.value = 'Code invalide. Veuillez réessayer.';
      isLoading.value = false;
    }
  }

  Future<void> resendOtp() async {
    clearError();
    try {
      final email = emailController.text.trim();
      await _repository.resendOtp(email: email.isNotEmpty ? email : null);
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = 'Erreur lors du renvoi du code';
    }
  }

  Future<void> forgotPassword() async {
    if (!(forgotPasswordFormKey.currentState?.validate() ?? false)) return;

    clearError();
    isLoading.value = true;

    try {
      final email = forgotPasswordEmailController.text.trim();
      await _repository.forgotPassword(email: email);

      isLoading.value = false;
      Get.toNamed(AppRoutes.resetPassword);
    } on ApiException catch (e) {
      isLoading.value = false;
      errorMessage.value = e.message;
    } catch (_) {
      isLoading.value = false;
      errorMessage.value = 'Erreur lors de l\'envoi. Vérifiez votre connexion.';
    }
  }

  Future<void> resetPassword() async {
    if (!(resetPasswordFormKey.currentState?.validate() ?? false)) return;

    clearError();
    isLoading.value = true;

    try {
      final email = forgotPasswordEmailController.text.trim();
      final code = resetCodeController.text.trim();
      final newPassword = newPasswordController.text;

      await _repository.resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
      );

      isLoading.value = false;
      Get.offAllNamed(AppRoutes.login);
    } on ApiException catch (e) {
      isLoading.value = false;
      errorMessage.value = e.message;
    } catch (_) {
      isLoading.value = false;
      errorMessage.value = 'Code invalide ou expiré. Veuillez réessayer.';
    }
  }

  Future<void> _fetchUserProfile() async {
    try {
      await _repository.me();
    } catch (_) {}
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
    } catch (_) {}
  }
}