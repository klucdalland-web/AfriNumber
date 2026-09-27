import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/widgets/widgets.dart';
import '../controllers/auth_controller.dart';

/// Formulaire "Mot de passe oublié" : demande l'email, envoie la requête
/// de réinitialisation, puis ouvre l'écran de saisie du code.
class ForgotPasswordForm extends StatelessWidget {
  const ForgotPasswordForm({super.key});

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    final controller = Get.find<AuthController>();

    return Form(
      key: controller.forgotPasswordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Mot de passe oublié ?',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: r.space(12)),
          Text(
            'Indiquez votre email : nous vous envoyons un code pour réinitialiser votre mot de passe.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
              height: 1.5,
            ),
          ),
          _ErrorBanner(controller: controller),
          SizedBox(height: r.space(36)),
          CustomTextField(
            hintText: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            controller: controller.forgotPasswordEmailController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'L\'email est requis';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Email invalide';
              }
              return null;
            },
            onSubmitted: (_) => controller.forgotPassword(),
          ),
          SizedBox(height: r.space(32)),
          Obx(
            () => AppButton.primary(
              label: 'Envoyer le code',
              isLoading: controller.isLoading.value,
              onPressed: controller.forgotPassword,
              backgroundColor: theme.colorScheme.onSurface,
              foregroundColor: theme.colorScheme.surface,
              radius: r.radius(28),
              height: r.heightOf(56),
            ),
          ),
          SizedBox(height: r.space(24)),
          AppButton.text(
            label: 'Retour à la connexion',
            onPressed: () => Get.offAllNamed(AppRoutes.login),
            foregroundColor: theme.colorScheme.onSurface,
            underline: true,
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.controller});

  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);

    return Obx(
      () => controller.errorMessage.isNotEmpty
          ? Container(
              margin: EdgeInsets.only(top: r.space(16)),
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
                      controller.errorMessage.value,
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
    );
  }
}
