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

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final _otpInputKey = GlobalKey<OTPInputState>();

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    final authController = Get.find<AuthController>();

    return AppScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: r.pad(h: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: r.space(20)),
              AuthHeader(moduleLabel: 'otp.title'.tr, showBackButton: true),
              SizedBox(height: r.space(8)),
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

              // Error message
              Obx(
                () => authController.errorMessage.isNotEmpty
                    ? Container(
                        margin: EdgeInsets.only(
                          top: r.space(16),
                          bottom: r.space(8),
                        ),
                        padding: EdgeInsets.all(r.space(12)),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(r.radius(12)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: theme.colorScheme.onErrorContainer,
                              size: r.iconSize(20),
                            ),
                            SizedBox(width: r.space(8)),
                            Expanded(
                              child: Text(
                                authController.errorMessage.value,
                                style: TextStyle(
                                  color: theme.colorScheme.onErrorContainer,
                                  fontSize: r.fontSize(14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              SizedBox(height: r.space(40)),
              OTPInput(
                key: _otpInputKey,
                length: 4,
                onCompleted: (code) => _handleVerifyOtp(authController, code),
                onChanged: (code) {
                  // Update the controller text for the numeric keypad sync
                  authController.otpController.text = code;
                },
              ),
              SizedBox(height: r.space(24)),
              _buildResendSection(r, theme, authController),
              SizedBox(height: r.space(32)),
              Obx(
                () => CustomNumericKeypad(
                  onDigitTap: (digit) {
                    _otpInputKey.currentState?.addDigit(digit);
                  },
                  onBackspaceTap: () {
                    _otpInputKey.currentState?.deleteLastDigit();
                  },
                  enabled: !authController.isLoading.value,
                  foregroundColor: theme.colorScheme.onSurface,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  disabledColor: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: r.space(24)),
              Obx(
                () => AppButton.outlined(
                  label: 'otp.back'.tr,
                  onPressed: authController.isLoading.value
                      ? null
                      : () => Get.back(),
                  foregroundColor: theme.colorScheme.onSurface,
                  radius: r.radius(28),
                  height: r.heightOf(56),
                ),
              ),
              SizedBox(height: r.space(40)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleVerifyOtp(AuthController controller, String code) async {
    if (code.length == 4) {
      controller.otpController.text = code;
      await controller.verifyOtp();
    }
  }

  Widget _buildResendSection(
    Responsive r,
    ThemeData theme,
    AuthController controller,
  ) {
    return Obx(
      () => Row(
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
            onPressed: controller.isLoading.value
                ? null
                : () => controller.resendOtp(),
            foregroundColor: theme.colorScheme.onSurface,
            underline: true,
          ),
        ],
      ),
    );
  }
}
