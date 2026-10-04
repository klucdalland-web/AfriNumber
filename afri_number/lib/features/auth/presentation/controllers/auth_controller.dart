import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/country_constants.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/utils/storage_service.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../domain/repositories/auth_repository.dart';

/// Contrôleur gérant les flux d'authentification (connexion, inscription, OTP, mot de passe oublié).
class AuthController extends GetxController {
  AuthController(this._repository, this._storage);

  final AuthRepository _repository;
  final StorageService _storage;

  final isLoading = false.obs;
  final rememberMe = false.obs;

  // Pays
  final countries = <CountryData>[].obs;
  final selectedCountry = Rxn<CountryData>();
  final isLoadingCountries = false.obs;

  final loginFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();
  final forgotPasswordFormKey = GlobalKey<FormState>();
  final resetPasswordFormKey = GlobalKey<FormState>();

  // Login controllers
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  // Contrôleurs du formulaire d'inscription
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

  // OTP : validité 10 min, 5 renvois maximum
  static const int otpValiditySeconds = 600;
  static const int maxOtpResends = 5;

  final otpRemainingSeconds = 0.obs;
  final otpResendCount = 0.obs;
  Timer? _otpTimer;
  DateTime? _otpExpiresAt;

  bool get isOtpExpired => otpRemainingSeconds.value <= 0;
  bool get canResendOtp => otpResendCount.value < maxOtpResends;
  int get otpResendsLeft => maxOtpResends - otpResendCount.value;

  String get otpTimerLabel {
    final s = otpRemainingSeconds.value;
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

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
    loadCountries();
  }

  @override
  void onClose() {
    _errorTimer?.cancel();
    _otpTimer?.cancel();
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
    errorMessage.value = msg;
    _errorTimer?.cancel();
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

  /// Normalise le numéro de téléphone au format international.
  String getNormalizedPhone(String rawInput) {
    var text = rawInput.trim().replaceAll(' ', '').replaceAll('-', '');
    if (text.isEmpty) return '';

    if (text.startsWith('+')) {
      final current = selectedCountry.value;
      if (current != null && text.startsWith(current.dialCode)) return text;

      for (final country in countries) {
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

    final dial = selectedCountry.value?.dialCode ?? '';
    return '$dial$text';
  }

  void startOtpTimer() {
    _otpTimer?.cancel();
    _otpExpiresAt = DateTime.now().add(
      const Duration(seconds: otpValiditySeconds),
    );
    _tickOtp();
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (_) => _tickOtp());
  }

  void _tickOtp() {
    final expiresAt = _otpExpiresAt;
    if (expiresAt == null) {
      otpRemainingSeconds.value = 0;
      return;
    }

    final remaining = expiresAt.difference(DateTime.now()).inSeconds;
    if (remaining <= 0) {
      otpRemainingSeconds.value = 0;
      _otpTimer?.cancel();
    } else {
      otpRemainingSeconds.value = remaining;
    }
  }

  void stopOtpTimer() {
    _otpTimer?.cancel();
    _otpTimer = null;
    otpRemainingSeconds.value = 0;
    _otpExpiresAt = null;
  }

  Future<void> loadCountries() async {
    if (isLoadingCountries.value) return;
    isLoadingCountries.value = true;
    try {
      final list = await _repository.getCountries();
      countries.assignAll(list);
      if (list.isNotEmpty) {
        selectedCountry.value =
            list.firstWhereOrNull((c) => c.code == 'MG') ?? list.first;
      }
    } catch (_) {
      setError('error.countries_load_failed'.tr);
    } finally {
      isLoadingCountries.value = false;
    }
  }

  /// Procédure de connexion de l'utilisateur.
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

  /// Procédure d'inscription.
  Future<void> register() async {
    if (isLoading.value) return;
    if (!(registerFormKey.currentState?.validate() ?? false)) return;

    final country = selectedCountry.value;
    if (country == null) {
      setError('error.country_required'.tr);
      return;
    }

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
        countryId: country.id,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      otpResendCount.value = 0;
      otpController.clear();
      startOtpTimer();
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

  /// Procédure de vérification du code OTP.
  Future<void> verifyOtp() async {
    if (isLoading.value) return;
    clearError();

    if (isOtpExpired) {
      setError('error.code_expired'.tr);
      return;
    }

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
      stopOtpTimer();
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

  /// Renvoie le code OTP.
  Future<void> resendOtp() async {
    if (isLoading.value) return;
    clearError();

    if (!canResendOtp) {
      setError('error.otp_resend_limit'.tr);
      return;
    }

    isLoading.value = true;
    try {
      final email = emailController.text.trim();
      await _repository.resendOtp(email: email.isNotEmpty ? email : null);
      otpResendCount.value++;
      otpController.clear();
      startOtpTimer();
    } on ApiException catch (e) {
      setError(e.message);
    } catch (_) {
      setError('error.code_resend_failed'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  /// Envoie la demande de réinitialisation de mot de passe.
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

  /// Réinitialise le mot de passe.
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

  /// Fonction récupérant les informations du profil utilisateur connecté depuis le backend.
  Future<void> _fetchUserProfile() async {
    try {
      final response = await _repository.me();
      if (response == null) return;

      final nestedUser = response['data'];
      final user = nestedUser is Map
          ? Map<String, dynamic>.from(nestedUser)
          : response;
      await _storage.saveUser(user);
    } catch (_) {
      debugPrint(
        '[AuthController] Impossible de récupérer le profil utilisateur.',
      );
    }
  }

  /// Déconnecte l'utilisateur.
  Future<void> logout() async {
    try {
      await _repository.logout();
    } catch (_) {
      await _storage.clearTokens();
    }
    Get.offAllNamed(AppRoutes.welcome);
  }
}
