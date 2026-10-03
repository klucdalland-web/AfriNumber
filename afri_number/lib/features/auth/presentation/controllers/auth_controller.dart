import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/country_constants.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/utils/storage_service.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthController extends GetxController {
  AuthController(this._repository, this._storage);

  final AuthRepository _repository;
  final StorageService _storage;
  final isLoading = false.obs;
  final rememberMe = false.obs;
  final selectedCountry = kCountries.first.obs;
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

  // OTP controller
  final otpController = TextEditingController();

  // Forgot / reset password controllers
  final forgotPasswordEmailController = TextEditingController();
  final resetCodeController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();

  final errorMessage = ''.obs;
  Timer? _errorTimer;

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
    _errorTimer?.cancel();
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

  void setError(String msg) {
    _errorTimer?.cancel();
    errorMessage.value = msg;
    AppDialog.showError(
      message: msg,
      autoDismissDuration: const Duration(seconds: 5),
    );
    _errorTimer = Timer(const Duration(seconds: 5), () {
      errorMessage.value = '';
    });
  }

  void clearError() {
    _errorTimer?.cancel();
    errorMessage.value = '';
  }

  void toggleRememberMe(bool value) => rememberMe.value = value;

  /// Factorise et normalise le numéro de téléphone au format international.
  /// (ex: "0341234567" avec +261 -> "+261341234567").
  String getNormalizedPhone(String rawInput) {
    var text = rawInput.trim().replaceAll(' ', '').replaceAll('-', '');
    if (text.isEmpty) return '';

    if (text.startsWith('+')) {
      for (final country in kCountries) {
        if (text.startsWith(country.dialCode)) {
          selectedCountry.value = country;
          return text;
        }
      }
      return text;
    }

    if (text.startsWith('0')) {
      text = text.substring(1);
    }

    return '${selectedCountry.value.dialCode}$text';
  }

  Future<void> login() async {
    if (isLoading.value) return;
    if (!(loginFormKey.currentState?.validate() ?? false)) return;

    clearError();
    isLoading.value = true;

    try {
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
      setError(e.message);
    } catch (_) {
      isLoading.value = false;
      setError('error.login_failed'.tr);
    }
  }

  Future<void> register() async {
    if (isLoading.value) return;
    if (!(registerFormKey.currentState?.validate() ?? false)) return;

    clearError();
    isLoading.value = true;

    try {
      final name = lastNameController.text.trim();
      final firstName = firstNameController.text.trim();
      final email = emailController.text.trim();
      final rawPhone = registerPhoneController.text.trim();
      final phoneNumber = getNormalizedPhone(rawPhone);
      registerPhoneController.text = phoneNumber;
      final password = registerPasswordController.text;
      final passwordConfirmation = confirmPasswordController.text;

      await _repository.register(
        name: name,
        firstName: firstName,
        email: email,
        phoneNumber: phoneNumber,
        countryId: selectedCountry.value.id,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      isLoading.value = false;
      Get.offAllNamed(AppRoutes.otpVerification);
    } on ApiException catch (e) {
      isLoading.value = false;
      setError(e.message);
    } catch (_) {
      isLoading.value = false;
      setError('error.register_failed'.tr);
    }
  }

  Future<void> verifyOtp() async {
    if (isLoading.value) return;
    clearError();
    isLoading.value = true;

    try {
      final code = otpController.text.trim();

      if (code.length != 4) {
        isLoading.value = false;
        setError('error.code_length'.tr);
        return;
      }

      final email = emailController.text.trim();
      await _repository.verifyOtp(
        code: code,
        email: email.isNotEmpty ? email : null,
      );

      await _fetchUserProfile();

      isLoading.value = false;
      Get.offAllNamed(AppRoutes.authFeedbackInscription);
    } on ApiException catch (e) {
      isLoading.value = false;
      setError(e.message);
    } catch (_) {
      isLoading.value = false;
      setError('error.code_invalid'.tr);
    }
  }

  Future<void> resendOtp() async {
    if (isLoading.value) return;
    clearError();
    isLoading.value = true;
    try {
      final email = emailController.text.trim();
      await _repository.resendOtp(email: email.isNotEmpty ? email : null);
    } on ApiException catch (e) {
      setError(e.message);
    } catch (_) {
      setError('error.code_resend_failed'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> forgotPassword() async {
    if (isLoading.value) return;
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
      setError(e.message);
    } catch (_) {
      isLoading.value = false;
      setError('error.email_send_failed'.tr);
    }
  }

  Future<void> resetPassword() async {
    if (isLoading.value) return;
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
      setError(e.message);
    } catch (_) {
      isLoading.value = false;
      setError('error.code_expired'.tr);
    }
  }

  Future<void> _fetchUserProfile() async {
    try {
      final response = await _repository.me();
      if (response == null) return;

      final nestedUser = response['data'];
      final user = nestedUser is Map
          ? Map<String, dynamic>.from(nestedUser)
          : response;
      await _storage.saveUser(user);
    } catch (_) {}
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
    } catch (_) {
      await _storage.clearTokens();
    }
    Get.offAllNamed(AppRoutes.welcome);
  }
}
