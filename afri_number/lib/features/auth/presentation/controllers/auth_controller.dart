import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phone_form_field/phone_form_field.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/country_constants.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/services/firebase_notification_service.dart';
import '../../../../core/utils/country_iso_mapper.dart';
import '../../../../core/utils/storage_service.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../domain/repositories/auth_repository.dart';

/// Contrôleur gérant les flux d'authentification (connexion, inscription, OTP, mot de passe oublié).
/// Aligné sur le contrat backend : validité 10 min, 5 tentatives puis lock 5 min,
/// cooldown de renvoi progressif (1 → 5 → 10 → 15 → 30 → 60 min).
class AuthController extends GetxController {
  AuthController(this._repository, this._storage, this._notifications);

  final AuthRepository _repository;
  final StorageService _storage;
  final FirebaseNotificationService _notifications;

  final isLoading = false.obs;
  final isVerifyingOtp = false.obs;
  final rememberMe = false.obs;

  /// Connexion : téléphone (défaut) ou e-mail.
  final loginWithEmail = false.obs;

  // Pays
  final countries = <CountryData>[].obs;
  final selectedCountry = Rxn<CountryData>();
  final isLoadingCountries = false.obs;
  final countriesLoadFailed = false.obs;

  final loginFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();
  final forgotPasswordFormKey = GlobalKey<FormState>();
  final resetPasswordFormKey = GlobalKey<FormState>();

  // Login controllers
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  late final PhoneController loginPhoneController;

  // Contrôleurs du formulaire d'inscription
  final lastNameController = TextEditingController();
  final firstNameController = TextEditingController();
  final emailController = TextEditingController();
  late final PhoneController registerPhoneController;
  final registerPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // OTP controller
  final otpController = TextEditingController();

  // Forgot / reset password controllers
  final forgotPasswordEmailController = TextEditingController();
  final resetCodeController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();

  // OTP : validité backend = 10 min ; max 5 tentatives incorrectes → lock 5 min
  static const int otpValiditySeconds = 600;
  static const int maxOtpAttempts = 5;
  static const String otpPurposeLogin = 'login';
  static const String otpPurposeRegister = 'register';
  static const int otpLength = 6;
  static const String _idTypeEmail = 'email';
  static const String _idTypePhone = 'phone';

  /// Contexte dans lequel la page OTP est ouverte : 'login' ou 'register'.
  String otpPurpose = otpPurposeRegister;

  /// Type d'identifiant utilisé pour verify/resend : email ou phone_number.
  String _otpIdentifierType = _idTypeEmail;

  final resendCooldown = 0.obs;
  Timer? _cooldownTimer;
  DateTime? _nextResendAt;

  bool get isResendCoolingDown => resendCooldown.value > 0;

  final otpRemainingSeconds = 0.obs;
  final otpResendCount = 0.obs;
  final otpLockRemainingSeconds = 0.obs;
  Timer? _otpTimer;
  Timer? _lockTimer;
  DateTime? _otpExpiresAt;
  DateTime? _otpLockedUntil;

  bool get isOtpExpired => otpRemainingSeconds.value <= 0;
  bool get isOtpLocked => otpLockRemainingSeconds.value > 0;

  /// Renvoi autorisé uniquement si pas de cooldown serveur ni de lock tentatives.
  bool get canResendOtp => !isResendCoolingDown && !isOtpLocked && !isLoading.value;

  String get otpTimerLabel => _formatMmSs(otpRemainingSeconds.value);

  String get resendCooldownLabel => _formatMmSs(resendCooldown.value);

  String get otpLockLabel => _formatMmSs(otpLockRemainingSeconds.value);

  final errorMessage = ''.obs;
  Timer? _errorTimer;

  List<IsoCode> get allowedIsoCodes =>
      CountryIsoMapper.allowedFrom(countries);

  static String _formatMmSs(int totalSeconds) {
    final s = totalSeconds.clamp(0, 999999);
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  @override
  void onInit() {
    super.onInit();
    loginPhoneController = PhoneController();
    registerPhoneController = PhoneController();

    final remembered = _storage.rememberedPhone;
    if (remembered != null && remembered.isNotEmpty) {
      rememberMe.value = true;
      _applyLoginIdentifier(remembered);
    }
    _restorePendingOtp();
    loadCountries();
  }

  void _applyLoginIdentifier(String identifier) {
    final trimmed = identifier.trim();
    if (trimmed.contains('@')) {
      loginWithEmail.value = true;
      phoneController.text = trimmed;
      return;
    }

    loginWithEmail.value = false;
    try {
      loginPhoneController.value = PhoneNumber.parse(trimmed);
    } catch (_) {
      phoneController.text = trimmed;
      loginWithEmail.value = true;
    }
  }

  void setLoginWithEmail(bool value) {
    loginWithEmail.value = value;
  }

  void _restorePendingOtp() {
    final pending = _storage.pendingOtp;
    if (pending == null) return;
    final purpose = pending['purpose'];
    final identifier = pending['identifier'];
    if ((purpose != otpPurposeLogin && purpose != otpPurposeRegister) ||
        identifier is! String ||
        identifier.isEmpty) {
      _storage.clearPendingOtp();
      return;
    }

    otpPurpose = purpose as String;
    final idType = pending['identifier_type'];
    if (idType == _idTypePhone || idType == _idTypeEmail) {
      _otpIdentifierType = idType as String;
    } else {
      _otpIdentifierType =
          identifier.contains('@') ? _idTypeEmail : _idTypePhone;
    }

    if (otpPurpose == otpPurposeLogin) {
      _applyLoginIdentifier(identifier);
    } else {
      emailController.text = identifier;
      _otpIdentifierType = _idTypeEmail;
    }

    final expiry = pending['expires_at'];
    final expiresAtMillis = expiry is int ? expiry : 0;
    _otpExpiresAt = DateTime.fromMillisecondsSinceEpoch(expiresAtMillis);
    _tickOtp();
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (_) => _tickOtp());

    final resendCount = pending['resend_count'];
    if (resendCount is int) {
      otpResendCount.value = resendCount;
    } else if (resendCount is num) {
      otpResendCount.value = resendCount.toInt();
    }

    final nextResend = pending['next_resend_at'];
    if (nextResend is int && nextResend > 0) {
      _startResendCooldownUntil(
        DateTime.fromMillisecondsSinceEpoch(nextResend),
      );
    }

    final lockedUntil = pending['locked_until'];
    if (lockedUntil is int && lockedUntil > 0) {
      _setOtpLockedUntil(DateTime.fromMillisecondsSinceEpoch(lockedUntil));
    }
  }

  Future<void> _savePendingOtp() => _storage.savePendingOtp(
        purpose: otpPurpose,
        identifier: _otpIdentifierValue ?? '',
        identifierType: _otpIdentifierType,
        expiresAtMillis:
            (_otpExpiresAt ?? DateTime.now()).millisecondsSinceEpoch,
        resendCount: otpResendCount.value,
        nextResendAtMillis: _nextResendAt?.millisecondsSinceEpoch,
        lockedUntilMillis: _otpLockedUntil?.millisecondsSinceEpoch,
      );

  @override
  void onClose() {
    _errorTimer?.cancel();
    _otpTimer?.cancel();
    _lockTimer?.cancel();
    phoneController.dispose();
    passwordController.dispose();
    loginPhoneController.dispose();
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
    _cooldownTimer?.cancel();
    super.onClose();
  }

  void setError(String msg) {
    errorMessage.value = msg;
    _errorTimer?.cancel();
    AppDialog.showError(
      message: msg,
      autoDismissDuration: const Duration(seconds: 5),
    ).catchError((Object error) {
      debugPrint('[AuthController] Could not show error dialog: $error');
    });
    _errorTimer = Timer(const Duration(seconds: 5), () {
      errorMessage.value = '';
    });
  }

  void clearError() {
    _errorTimer?.cancel();
    errorMessage.value = '';
  }

  void toggleRememberMe(bool value) => rememberMe.value = value;

  /// Numéro E.164 sans espaces ni tirets (ex. `+242060000000`).
  String toE164(PhoneNumber number) => number.international;

  void onPhoneChanged(PhoneNumber number) {
    final match = CountryIsoMapper.findCountry(countries, number.isoCode);
    if (match == null) return;
    if (selectedCountry.value?.id != match.id) {
      selectedCountry.value = match;
      _storage.savePreferredCountryCode(match.code);
    }
  }

  void _applyDefaultCountryToPhoneControllers(CountryData country) {
    final iso = CountryIsoMapper.tryParse(country.code);
    if (iso == null) return;
    if (loginPhoneController.value.nsn.trim().isEmpty &&
        loginPhoneController.value.isoCode != iso) {
      loginPhoneController.changeCountry(iso);
    }
    if (registerPhoneController.value.nsn.trim().isEmpty &&
        registerPhoneController.value.isoCode != iso) {
      registerPhoneController.changeCountry(iso);
    }
  }

  String? get _otpIdentifierValue {
    if (otpPurpose == otpPurposeLogin) {
      if (_otpIdentifierType == _idTypeEmail || loginWithEmail.value) {
        final value = phoneController.text.trim();
        return value.isNotEmpty ? value : null;
      }
      final number = loginPhoneController.value;
      if (number.nsn.trim().isEmpty) return null;
      return toE164(number);
    }
    final value = emailController.text.trim();
    return value.isNotEmpty ? value : null;
  }

  String? get _otpEmail =>
      _otpIdentifierType == _idTypeEmail ? _otpIdentifierValue : null;

  String? get _otpPhoneNumber =>
      _otpIdentifierType == _idTypePhone ? _otpIdentifierValue : null;

  void _prepareOtpSession({
    required String purpose,
    required String identifier,
    required String identifierType,
  }) {
    otpPurpose = purpose;
    _otpIdentifierType = identifierType;
    otpController.clear();
    _clearOtpLock();
  }

  /// Applique la meta renvoyée par login / register / resend-otp.
  void _applyOtpSendMeta(Map<String, dynamic>? data) {
    if (data == null) return;

    final count = ApiException.asInt(data['resend_count']);
    if (count != null) otpResendCount.value = count;

    final nextAtRaw = data['next_resend_at'];
    if (nextAtRaw is String && nextAtRaw.isNotEmpty) {
      final parsed = DateTime.tryParse(nextAtRaw)?.toLocal();
      if (parsed != null) {
        _startResendCooldownUntil(parsed);
        return;
      }
    }

    final waitMinutes = ApiException.asInt(data['next_resend_wait_minutes']);
    if (waitMinutes != null && waitMinutes > 0) {
      _startResendCooldownUntil(
        DateTime.now().add(Duration(minutes: waitMinutes)),
      );
    }
  }

  /// Synchronise cooldown / lock depuis une erreur 423 / 429.
  void _applyThrottleFromException(ApiException e) {
    final count = e.resendCount;
    if (count != null) otpResendCount.value = count;

    final nextResend = e.nextResendAt;
    final retrySeconds = e.retryAfterSeconds;
    if (nextResend != null) {
      _startResendCooldownUntil(nextResend);
    } else if (retrySeconds != null && retrySeconds > 0) {
      _startResendCooldownUntil(
        DateTime.now().add(Duration(seconds: retrySeconds)),
      );
    }

    if (e.isLocked) {
      final lockedUntil = e.lockedUntil;
      if (lockedUntil != null) {
        _setOtpLockedUntil(lockedUntil);
      } else {
        final minutes = e.lockedMinutesLeft ?? 5;
        _setOtpLockedUntil(DateTime.now().add(Duration(minutes: minutes)));
      }
    }
  }

  Future<void> startOtpTimer() async {
    _otpTimer?.cancel();
    _otpExpiresAt = DateTime.now().add(
      const Duration(seconds: otpValiditySeconds),
    );
    await _savePendingOtp();
    _tickOtp();
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (_) => _tickOtp());
  }

  void _startResendCooldownUntil(DateTime availableAt) {
    _cooldownTimer?.cancel();
    _nextResendAt = availableAt;
    _tickResendCooldown();
    _cooldownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _tickResendCooldown(),
    );
    _savePendingOtp();
  }

  void _tickResendCooldown() {
    final availableAt = _nextResendAt;
    if (availableAt == null) {
      resendCooldown.value = 0;
      return;
    }
    final remaining = availableAt.difference(DateTime.now()).inSeconds;
    if (remaining <= 0) {
      resendCooldown.value = 0;
      _nextResendAt = null;
      _cooldownTimer?.cancel();
      _savePendingOtp();
    } else {
      resendCooldown.value = remaining;
    }
  }

  void stopResendCooldown() {
    _cooldownTimer?.cancel();
    _cooldownTimer = null;
    resendCooldown.value = 0;
    _nextResendAt = null;
  }

  void _setOtpLockedUntil(DateTime until) {
    _lockTimer?.cancel();
    _otpLockedUntil = until;
    _tickOtpLock();
    _lockTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _tickOtpLock(),
    );
    _savePendingOtp();
  }

  void _tickOtpLock() {
    final until = _otpLockedUntil;
    if (until == null) {
      otpLockRemainingSeconds.value = 0;
      return;
    }
    final remaining = until.difference(DateTime.now()).inSeconds;
    if (remaining <= 0) {
      _clearOtpLock();
      _savePendingOtp();
    } else {
      otpLockRemainingSeconds.value = remaining;
    }
  }

  void _clearOtpLock() {
    _lockTimer?.cancel();
    _lockTimer = null;
    _otpLockedUntil = null;
    otpLockRemainingSeconds.value = 0;
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
    stopResendCooldown();
    _clearOtpLock();
  }

  Map<String, dynamic>? _asDataMap(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }

  Future<void> loadCountries() async {
    if (isLoadingCountries.value) return;
    isLoadingCountries.value = true;
    countriesLoadFailed.value = false;
    try {
      final list = await _repository.getCountries();
      countries.assignAll(list);

      if (list.isEmpty) {
        selectedCountry.value = null;
        return;
      }

      // Numéro déjà saisi (ex. « se souvenir de moi ») → conserve son pays.
      if (loginPhoneController.value.nsn.trim().isNotEmpty) {
        final fromPhone = CountryIsoMapper.findCountry(
          list,
          loginPhoneController.value.isoCode,
        );
        if (fromPhone != null) {
          selectedCountry.value = fromPhone;
          final iso = CountryIsoMapper.tryParse(fromPhone.code);
          if (iso != null && registerPhoneController.value.nsn.isEmpty) {
            registerPhoneController.changeCountry(iso);
          }
          return;
        }
      }

      final preferredCode = _storage.preferredCountryCode;
      final preferred = preferredCode == null
          ? null
          : list.firstWhereOrNull((c) => c.code == preferredCode);
      final current = selectedCountry.value;
      final stillValid = current != null &&
          list.any((c) => c.id == current.id) &&
          CountryIsoMapper.tryParse(current.code) != null;

      final chosen = stillValid
          ? list.firstWhere((c) => c.id == current.id)
          : preferred ??
              list.firstWhereOrNull(
                (c) => CountryIsoMapper.tryParse(c.code) != null,
              ) ??
              list.first;

      selectedCountry.value = chosen;
      if (CountryIsoMapper.tryParse(chosen.code) != null) {
        _applyDefaultCountryToPhoneControllers(chosen);
      }
    } catch (_) {
      countriesLoadFailed.value = true;
      countries.clear();
    } finally {
      isLoadingCountries.value = false;
    }
  }

  /// Vide les champs du formulaire de connexion (identifiants incorrects, etc.).
  void _clearLoginFields() {
    phoneController.clear();
    passwordController.clear();
    final iso = loginPhoneController.value.isoCode;
    loginPhoneController.value = PhoneNumber(isoCode: iso, nsn: '');
    loginFormKey.currentState?.reset();
  }

  /// Procédure de connexion de l'utilisateur.
  Future<void> login() async {
    if (isLoading.value) return;
    if (!(loginFormKey.currentState?.validate() ?? false)) return;

    clearError();
    isLoading.value = true;

    try {
      final String identifier;
      final String idType;
      if (loginWithEmail.value) {
        identifier = phoneController.text.trim();
        idType = _idTypeEmail;
      } else {
        identifier = toE164(loginPhoneController.value);
        idType = _idTypePhone;
        onPhoneChanged(loginPhoneController.value);
      }
      final password = passwordController.text;

      final response = await _repository.login(
        email: identifier,
        password: password,
      );

      if (rememberMe.value) {
        await _storage.saveRememberedPhone(identifier);
      } else {
        await _storage.clearRememberedPhone();
      }

      _prepareOtpSession(
        purpose: otpPurposeLogin,
        identifier: identifier,
        identifierType: idType,
      );
      _applyOtpSendMeta(_asDataMap(response));
      await startOtpTimer();
      isLoading.value = false;
      Get.toNamed(AppRoutes.otpVerification);
    } on ApiException catch (e) {
      isLoading.value = false;
      _applyThrottleFromException(e);
      // Mot de passe / identifiants incorrects → reset complet du formulaire.
      _clearLoginFields();
      setError(e.displayMessage);
    } catch (_) {
      isLoading.value = false;
      _clearLoginFields();
      setError('error.login_failed'.tr);
    }
  }

  /// Procédure d'inscription.
  Future<void> register() async {
    if (isLoading.value) return;
    if (!(registerFormKey.currentState?.validate() ?? false)) return;

    final phoneNumber = registerPhoneController.value;
    onPhoneChanged(phoneNumber);

    final country = selectedCountry.value ??
        CountryIsoMapper.findCountry(countries, phoneNumber.isoCode);
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
      final e164 = toE164(phoneNumber);
      final password = registerPasswordController.text;
      final passwordConfirmation = confirmPasswordController.text;

      final response = await _repository.register(
        name: name,
        firstName: firstName,
        email: email,
        phoneNumber: e164,
        countryId: country.id,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      await _storage.savePreferredCountryCode(country.code);

      _prepareOtpSession(
        purpose: otpPurposeRegister,
        identifier: email,
        identifierType: _idTypeEmail,
      );
      _applyOtpSendMeta(_asDataMap(response));
      await startOtpTimer();
      isLoading.value = false;
      Get.offAllNamed(AppRoutes.otpVerification);
    } on ApiException catch (e) {
      isLoading.value = false;
      _applyThrottleFromException(e);
      setError(e.displayMessage);
    } catch (_) {
      isLoading.value = false;
      setError('error.register_failed'.tr);
    }
  }

  /// Procédure de vérification du code OTP.
  /// Retourne `true` en cas de succès, `false` sinon (les cases doivent être vidées).
  Future<bool> verifyOtp() async {
    if (isLoading.value || isVerifyingOtp.value) return false;
    clearError();

    if (isOtpLocked) {
      setError(
        'otp.locked'.trParams({'time': otpLockLabel}),
      );
      otpController.clear();
      return false;
    }

    if (isOtpExpired) {
      setError('error.code_expired'.tr);
      otpController.clear();
      return false;
    }

    isLoading.value = true;
    isVerifyingOtp.value = true;
    try {
      final code = otpController.text.trim();
      if (code.length != otpLength) {
        isLoading.value = false;
        isVerifyingOtp.value = false;
        setError('error.code_length'.tr);
        otpController.clear();
        return false;
      }

      final response = await _repository.verifyOtp(
        code: code,
        purpose: otpPurpose,
        email: _otpEmail,
        phoneNumber: _otpPhoneNumber,
      );
      if (response['success'] == false) {
        final message = response['message'];
        throw ApiException(
          message: message is String && message.isNotEmpty
              ? message
              : 'error.code_invalid'.tr,
        );
      }

      final data = response['data'];
      final user = data is Map ? data['user'] : null;
      if (user is Map) {
        await _storage.saveUser(Map<String, dynamic>.from(user));
      }
      stopOtpTimer();
      await _storage.clearPendingOtp();
      isLoading.value = false;
      // Token JWT dispo → synchronise le FCM token réel avec le backend.
      _notifications.syncTokenWithBackend();
      Get.offAllNamed(
        otpPurpose == otpPurposeLogin
            ? AppRoutes.authFeedbackConnexion
            : AppRoutes.authFeedbackInscription,
      );
      return true;
    } on ApiException catch (e) {
      isLoading.value = false;
      _applyThrottleFromException(e);
      otpController.clear();
      setError(e.displayMessage);
      return false;
    } catch (_) {
      isLoading.value = false;
      otpController.clear();
      setError('error.code_invalid'.tr);
      return false;
    } finally {
      isVerifyingOtp.value = false;
      isLoading.value = false;
    }
  }

  /// Renvoie le code OTP.
  Future<void> resendOtp() async {
    if (isLoading.value) return;
    if (isResendCoolingDown) return;
    if (isOtpLocked) {
      setError('otp.locked'.trParams({'time': otpLockLabel}));
      return;
    }
    clearError();

    isLoading.value = true;
    try {
      final response = await _repository.resendOtp(
        purpose: otpPurpose,
        email: _otpEmail,
        phoneNumber: _otpPhoneNumber,
      );
      _applyOtpSendMeta(_asDataMap(response));
      otpController.clear();
      _clearOtpLock();
      await startOtpTimer();
    } on ApiException catch (e) {
      _applyThrottleFromException(e);
      setError(e.displayMessage);
    } catch (_) {
      setError('error.code_resend_failed'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> leaveOtpFlow() async {
    stopOtpTimer();
    otpController.clear();
    try {
      await _storage.clearPendingOtp();
      await _storage.clearTokens();
    } catch (error) {
      debugPrint('[AuthController] Could not clear pending OTP state: $error');
    } finally {
      Get.offAllNamed(
        otpPurpose == otpPurposeLogin ? AppRoutes.login : AppRoutes.register,
      );
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
      setError(e.displayMessage);
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
      final confirmation = confirmNewPasswordController.text;

      await _repository.resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
        passwordConfirmation: confirmation,
      );

      isLoading.value = false;
      Get.offAllNamed(AppRoutes.login);
    } on ApiException catch (e) {
      isLoading.value = false;
      setError(e.displayMessage);
    } catch (_) {
      isLoading.value = false;
      setError('error.reset_failed'.tr);
    }
  }

  /// Déconnecte l'utilisateur.
  Future<void> logout() async {
    try {
      await _repository.logout();
    } catch (_) {
      try {
        await _storage.clearTokens();
      } catch (error) {
        debugPrint('[AuthController] Could not clear auth tokens: $error');
      }
    } finally {
      Get.offAllNamed(AppRoutes.welcome);
    }
  }
}
