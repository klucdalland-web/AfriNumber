import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/widgets.dart';
import '../controllers/auth_controller.dart';
import '../widgets/widgets.dart';

class OTPVerificationPage extends StatefulWidget {
  const OTPVerificationPage({super.key});

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage>
    with SingleTickerProviderStateMixin {
  final _otpInputKey = GlobalKey<OTPInputState>();

  // Accès au controller en dehors du build pour éviter Get.find() répétitif
  late final AuthController _authController;

  // Animation d'entrée de page
  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _authController = Get.find<AuthController>();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );

    _fadeAnim = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    ));

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  // ───────────────────────────────────────────── actions

  Future<void> _handleVerifyOtp(String code) async {
    if (code.length != AuthController.otpLength) return;
    // Synchronise le code dans le controller avant l'appel réseau
    _authController.otpController.text = code;
    final ok = await _authController.verifyOtp();
    // Après l'await : si la page est disposée (navigation réussie), on arrête
    if (!mounted) return;
    // Code incorrect / expiré / lock → vide les cases pour une nouvelle saisie
    if (!ok) _clearOtpInput();
  }

  Future<void> _handleResend() async {
    await _authController.resendOtp();
    // Après l'await : vérifier mounted AVANT tout accès aux widgets
    if (!mounted) return;
    // Efface tous les champs OTP (le controller a déjà fait otpController.clear())
    _clearOtpInput();
  }

  /// Efface proprement les cases OTP via le GlobalKey.
  void _clearOtpInput() {
    final state = _otpInputKey.currentState;
    if (state == null) return;
    state.clear();
  }

  // ───────────────────────────────────────────── build

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);

    return AppScaffold(
      body: SafeArea(
        child: Stack(
          children: [
            FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: r.pad(h: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: r.space(20)),
                      AuthHeader(moduleLabel: 'otp.title'.tr),
                      SizedBox(height: r.space(8)),
                      _buildHeading(r, theme),
                      _buildErrorBanner(r, theme),
                      SizedBox(height: r.space(16)),
                      _buildTimerRow(r, theme),
                      SizedBox(height: r.space(16)),
                      OTPInput(
                        key: _otpInputKey,
                        length: AuthController.otpLength,
                        onCompleted: _handleVerifyOtp,
                        onChanged: (code) {
                          if (mounted) {
                            _authController.otpController.text = code;
                          }
                        },
                      ),
                      SizedBox(height: r.space(24)),
                      _buildResendSection(r, theme),
                      SizedBox(height: r.space(40)),
                    ],
                  ),
                ),
              ),
            ),
            Obx(
              () => _authController.isVerifyingOtp.value
                  ? Positioned.fill(
                      child: ColoredBox(
                        color: theme.scaffoldBackgroundColor,
                        child: _buildVerifyingScreen(r, theme),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────── sous-widgets

  Widget _buildVerifyingScreen(Responsive r, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: r.iconSize(44),
            height: r.iconSize(44),
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: r.space(20)),
          Text(
            'otp.verifying'.tr,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeading(Responsive r, ThemeData theme) {
    return Column(
      children: [
        Text(
          'otp.title'.tr,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: r.space(12)),
        Text(
          'otp.subtitle'.tr,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  /// Bannière d'erreur — n'occupe aucun espace quand vide.
  Widget _buildErrorBanner(Responsive r, ThemeData theme) {
    return Obx(() {
      final msg = _authController.errorMessage.value;
      if (msg.isEmpty) return const SizedBox.shrink();

      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: EdgeInsets.only(top: r.space(16), bottom: r.space(4)),
        padding: EdgeInsets.symmetric(
          horizontal: r.space(14),
          vertical: r.space(12),
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(r.radius(12)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: theme.colorScheme.onErrorContainer,
              size: r.iconSize(20),
            ),
            SizedBox(width: r.space(10)),
            Expanded(
              child: Text(
                msg,
                style: TextStyle(
                  color: theme.colorScheme.onErrorContainer,
                  fontSize: r.fontSize(14),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Ligne minuterie : arc circulaire de progression + libellé textuel.
  Widget _buildTimerRow(Responsive r, ThemeData theme) {
    return Obx(() {
      final expired = _authController.isOtpExpired;
      final remaining = _authController.otpRemainingSeconds.value;
      const total = AuthController.otpValiditySeconds;
      final progress = expired ? 0.0 : (remaining / total).clamp(0.0, 1.0);

      final timerColor = expired
          ? theme.colorScheme.error
          : (progress < 0.25
              ? theme.colorScheme.error
              : theme.colorScheme.primary);

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Arc de progression circulaire
          SizedBox(
            width: r.iconSize(28),
            height: r.iconSize(28),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: progress, end: progress),
              duration: const Duration(milliseconds: 400),
              builder: (_, value, _) => CircularProgressIndicator(
                value: value,
                strokeWidth: 3,
                backgroundColor:
                    theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                valueColor: AlwaysStoppedAnimation(timerColor),
                strokeCap: StrokeCap.round,
              ),
            ),
          ),
          SizedBox(width: r.space(10)),
          Text(
            expired
                ? 'otp.expired'.tr
                : '${'otp.expires_in'.tr} ${_authController.otpTimerLabel}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: timerColor,
            ),
          ),
        ],
      );
    });
  }

  /// Section "Vous n'avez pas reçu de code ? Renvoyer"
  Widget _buildResendSection(Responsive r, ThemeData theme) {
    return Obx(() {
      final locked = _authController.isOtpLocked;
      final coolingDown = _authController.isResendCoolingDown;
      final isLoading = _authController.isLoading.value;
      final canResend = _authController.canResendOtp;

      final hintColor = (locked || coolingDown)
          ? (locked
              ? theme.colorScheme.error
              : theme.colorScheme.onSurface.withValues(alpha: 0.55))
          : theme.colorScheme.onSurface.withValues(alpha: 0.5);

      final String hint;
      if (locked) {
        hint = 'otp.locked'.trParams({'time': _authController.otpLockLabel});
      } else if (coolingDown) {
        hint = 'otp.resend_in'.trParams({
          'time': _authController.resendCooldownLabel,
        });
      } else {
        hint = 'otp.resend_ready'.tr;
      }

      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${'otp.no_code_received'.tr} ',
                style: TextStyle(
                  fontSize: r.fontSize(14),
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
              AppButton.text(
                label: 'otp.resend'.tr,
                onPressed: canResend && !isLoading ? _handleResend : null,
                foregroundColor: theme.colorScheme.onSurface,
                underline: true,
              ),
            ],
          ),
          SizedBox(height: r.space(4)),
          Text(
            hint,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: r.fontSize(12),
              color: hintColor,
            ),
          ),
        ],
      );
    });
  }

}
