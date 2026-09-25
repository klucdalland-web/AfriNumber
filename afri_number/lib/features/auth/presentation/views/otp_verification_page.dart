import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/widgets.dart';
import '../../../../app/routes/app_routes.dart';
import '../controllers/auth_controller.dart';
import '../widgets/widgets.dart';

class OTPVerificationPage extends StatelessWidget {
  const OTPVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: r.pad(h: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: r.space(20)),
              AuthHeader(
                moduleLabel: 'Vérification',
                showBackButton: true,
              ),
              SizedBox(height: r.space(8)),
              Text(
                'Code de vérification',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: r.space(12)),
              Text(
                'Entrez le code à 4 chiffres envoyé à votre numéro pour continuer.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                  height: 1.5,
                ),
              ),
              
              // Error message
              Obx(() => authController.errorMessage.isNotEmpty
                  ? Container(
                      margin: EdgeInsets.only(top: r.space(16), bottom: r.space(8)),
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
                  : const SizedBox.shrink()),

              SizedBox(height: r.space(40)),
              OTPInput(
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
              CustomNumericKeypad(
                onDigitTap: (digit) => _onDigitTap(authController, digit),
                onBackspaceTap: () => _onBackspaceTap(authController),
                enabled: !authController.isLoading.value,
              ),
              SizedBox(height: r.space(24)),
              SizedBox(
                height: r.heightOf(56),
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: authController.isLoading.value ? null : () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurface,
                    side: BorderSide(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(r.radius(28)),
                    ),
                    textStyle: TextStyle(
                      fontSize: r.fontSize(16),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                  child: Text('Retour'),
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
      final success = await controller.verifyOtp();
      if (success) {
        Get.offAllNamed(AppRoutes.successConfirmation,
            arguments: {'variant': 'register'});
      }
    }
  }

  void _onDigitTap(AuthController controller, int digit) {
    final text = controller.otpController.text;
    if (text.length < 4) {
      controller.otpController.text = text + digit.toString();
    }
  }

  void _onBackspaceTap(AuthController controller) {
    final text = controller.otpController.text;
    if (text.isNotEmpty) {
      controller.otpController.text = text.substring(0, text.length - 1);
    }
  }

  Widget _buildResendSection(Responsive r, ThemeData theme, AuthController controller) {
    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Vous n\'avez pas reçu le code ? ',
          style: TextStyle(
            fontSize: r.fontSize(14),
            fontWeight: FontWeight.w400,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
        TextButton(
          onPressed: controller.isLoading.value ? null : () => controller.resendOtp(),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Renvoyer',
            style: TextStyle(
              fontSize: r.fontSize(14),
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
              decoration: TextDecoration.underline,
              decorationColor: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    ));
  }
}