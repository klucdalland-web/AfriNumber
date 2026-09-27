import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/widgets.dart';
import '../controllers/auth_controller.dart';

/// Formulaire de réinitialisation : code reçu par email + nouveau mot de
/// passe. Ramène à l'écran de connexion une fois validé.
class ResetPasswordForm extends StatelessWidget {
  const ResetPasswordForm({super.key});

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    final controller = Get.find<AuthController>();

    return Form(
      key: controller.resetPasswordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Nouveau mot de passe',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: r.space(12)),
          Text(
            'Entrez le code reçu par email et choisissez votre nouveau mot de passe.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
              height: 1.5,
            ),
          ),
          _ErrorBanner(controller: controller),
          SizedBox(height: r.space(36)),
          CustomTextField(
            hintText: 'Code reçu par email',
            icon: Icons.pin_outlined,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            controller: controller.resetCodeController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Le code est requis';
              }
              return null;
            },
          ),
          SizedBox(height: r.space(20)),
          CustomTextField(
            hintText: 'Nouveau mot de passe',
            icon: Icons.lock_outline,
            isPassword: true,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
            controller: controller.newPasswordController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Le mot de passe est requis';
              }
              if (value.length < 8) {
                return 'Minimum 8 caractères';
              }
              return null;
            },
          ),
          SizedBox(height: r.space(20)),
          CustomTextField(
            hintText: 'Confirmer le mot de passe',
            icon: Icons.lock_outline,
            isPassword: true,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
            controller: controller.confirmNewPasswordController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Confirmez le mot de passe';
              }
              if (value != controller.newPasswordController.text) {
                return 'Les mots de passe ne correspondent pas';
              }
              return null;
            },
            onSubmitted: (_) => controller.resetPassword(),
          ),
          SizedBox(height: r.space(32)),
          Obx(
            () => AppButton.primary(
              label: 'Réinitialiser',
              isLoading: controller.isLoading.value,
              onPressed: controller.resetPassword,
              backgroundColor: theme.colorScheme.onSurface,
              foregroundColor: theme.colorScheme.surface,
              radius: r.radius(28),
              height: r.heightOf(56),
            ),
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
