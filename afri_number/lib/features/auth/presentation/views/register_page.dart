import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/widgets.dart';
import '../../../../app/routes/app_routes.dart';
import '../controllers/auth_controller.dart';
import '../widgets/widgets.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

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
          child: Form(
            key: authController.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: r.space(20)),
                AuthHeader(moduleLabel: 'Inscription'),
                SizedBox(height: r.space(8)),
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
                
                // Error message
                Obx(() => authController.errorMessage.isNotEmpty
                    ? Container(
                        margin: EdgeInsets.only(bottom: r.space(16)),
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

                SizedBox(height: r.space(36)),
                AuthInputField(
                  hintText: 'Nom *',
                  icon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.familyName],
                  controller: authController.lastNameController,
                  isRequired: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le nom est requis';
                    }
                    return null;
                  },
                ),
                SizedBox(height: r.space(20)),
                AuthInputField(
                  hintText: 'Prénom(s)',
                  icon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.givenName],
                  controller: authController.firstNameController,
                ),
                SizedBox(height: r.space(20)),
                AuthInputField(
                  hintText: 'Email *',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  controller: authController.emailController,
                  isRequired: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'L\'email est requis';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Email invalide';
                    }
                    return null;
                  },
                ),
                SizedBox(height: r.space(20)),
                AuthInputField(
                  hintText: 'Mot de passe *',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                  controller: authController.registerPasswordController,
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
                AuthInputField(
                  hintText: 'Confirmer *',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.newPassword],
                  controller: authController.confirmPasswordController,
                  isRequired: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirmez le mot de passe';
                    }
                    if (value != authController.registerPasswordController.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                  onSubmitted: (_) => _handleRegister(authController),
                ),
                SizedBox(height: r.space(28)),
                TextButton(
                  onPressed: () => Get.toNamed(AppRoutes.login),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Déjà inscrit ? Se Connecter',
                    style: TextStyle(
                      fontSize: r.fontSize(15),
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                      decoration: TextDecoration.underline,
                      decorationColor: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                SizedBox(height: r.space(16)),
                Obx(
                  () => SizedBox(
                    height: r.heightOf(56),
                    child: ElevatedButton(
                      onPressed: authController.isLoading.value
                          ? null
                          : () => _handleRegister(authController),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.onSurface,
                        foregroundColor: theme.colorScheme.surface,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(r.radius(28)),
                        ),
                        textStyle: TextStyle(
                          fontSize: r.fontSize(16),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                      child: authController.isLoading.value
                          ? SizedBox(
                              width: r.iconSize(24),
                              height: r.iconSize(24),
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: theme.colorScheme.surface,
                              ),
                            )
                          : Text('Continuer'),
                    ),
                  ),
                ),
                SizedBox(height: r.space(32)),
                _buildLegalText(r, theme),
                SizedBox(height: r.space(40)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleRegister(AuthController controller) async {
    if (controller.formKey.currentState?.validate() ?? false) {
      final success = await controller.register();
      if (success) {
        controller.navigateAfterAuth(true);
      }
    }
  }

  Widget _buildLegalText(Responsive r, ThemeData theme) {
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