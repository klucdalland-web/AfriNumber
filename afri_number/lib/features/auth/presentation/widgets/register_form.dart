import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/widgets/widgets.dart';
import '../controllers/auth_controller.dart';

/// Formulaire d'inscription complet (titre, champs, mentions légales,
/// bouton de soumission et lien de connexion). Autonome : `RegisterPage`
/// se contente de l'instancier sous le `AuthHeader`.
class RegisterForm extends StatelessWidget {
  const RegisterForm({super.key});

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    final controller = Get.find<AuthController>();

    return Form(
      key: controller.registerFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Créer un compte',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: r.space(12)),
          Text(
            'Rejoignez-nous en quelques clics !',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
              height: 1.5,
            ),
          ),
          _ErrorBanner(controller: controller),
          SizedBox(height: r.space(36)),
          CustomTextField(
            hintText: 'Nom *',
            icon: Icons.person_outline,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.familyName],
            controller: controller.lastNameController,
            isRequired: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Le nom est requis';
              }
              return null;
            },
          ),
          SizedBox(height: r.space(20)),
          CustomTextField(
            hintText: 'Prénom(s)',
            icon: Icons.person_outline,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.givenName],
            controller: controller.firstNameController,
          ),
          SizedBox(height: r.space(20)),
          CustomTextField(
            hintText: 'Email *',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            controller: controller.emailController,
            isRequired: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'L\'email est requis';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Email invalide';
              }
              return null;
            },
          ),
          SizedBox(height: r.space(20)),
          // Champ requis par le backend (/auth/register attend
          // phone_number) mais absent de la maquette Figma pour l'écran
          // SignUp.
          CustomTextField(
            hintText: 'Téléphone *',
            icon: Icons.call_outlined,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.telephoneNumber],
            controller: controller.registerPhoneController,
            isRequired: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Le téléphone est requis';
              }
              return null;
            },
          ),
          SizedBox(height: r.space(20)),
          CustomTextField(
            hintText: 'Mot de passe *',
            icon: Icons.lock_outline,
            isPassword: true,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
            controller: controller.registerPasswordController,
            isRequired: true,
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
            hintText: 'Confirmer *',
            icon: Icons.lock_outline,
            isPassword: true,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
            controller: controller.confirmPasswordController,
            isRequired: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Confirmez le mot de passe';
              }
              if (value != controller.registerPasswordController.text) {
                return 'Les mots de passe ne correspondent pas';
              }
              return null;
            },
            onSubmitted: (_) => controller.register(),
          ),
          SizedBox(height: r.space(28)),
          AppButton.text(
            label: 'Déjà inscrit ? Se Connecter',
            onPressed: () => Get.toNamed(AppRoutes.login),
            foregroundColor: theme.colorScheme.onSurface,
            underline: true,
          ),
          SizedBox(height: r.space(16)),
          Obx(
            () => AppButton.primary(
              label: 'Continuer',
              isLoading: controller.isLoading.value,
              onPressed: controller.register,
              backgroundColor: theme.colorScheme.onSurface,
              foregroundColor: theme.colorScheme.surface,
              radius: r.radius(28),
              height: r.heightOf(56),
            ),
          ),
          SizedBox(height: r.space(32)),
          _LegalText(),
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

class _LegalText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);

    return Text(
      'En continuant, vous acceptez nos '
      'Conditions d\'utilisation et notre Politique de confidentialité.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: r.fontSize(12),
        fontWeight: FontWeight.w400,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        height: 1.5,
      ),
    );
  }
}
