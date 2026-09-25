import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/widgets/widgets.dart';
import '../controllers/auth_controller.dart';
import '../widgets/widgets.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
                AuthHeader(moduleLabel: 'Connexion'),
                SizedBox(height: r.space(8)),
                Text(
                  'De Retour !',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: r.space(12)),
                Text(
                  'Heureux de vous revoir ! Connectez-vous pour continuer là où vous vous êtes arrêté.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                    height: 1.5,
                  ),
                ),
                
                // Message d'erreur
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
                  hintText: 'Email ou téléphone',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  controller: authController.phoneController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email ou téléphone requis';
                    }
                    return null;
                  },
                ),
                SizedBox(height: r.space(20)),
                AuthInputField(
                  hintText: 'Mot de passe',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  controller: authController.passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le mot de passe est requis';
                    }
                    if (value.length < 6) {
                      return 'Minimum 6 caractères';
                    }
                    return null;
                  },
                  onSubmitted: (_) => _handleLogin(authController),
                ),
                SizedBox(height: r.space(20)),
                _buildOptionsRow(r, theme),
                SizedBox(height: r.space(32)),
                _buildSocialButtons(r, theme),
                SizedBox(height: r.space(32)),
                Obx(
                  () => SizedBox(
                    height: r.heightOf(56),
                    child: ElevatedButton(
                      onPressed: authController.isLoading.value
                          ? null
                          : () => _handleLogin(authController),
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
                          : const Text('Connexion'),
                    ),
                  ),
                ),
                SizedBox(height: r.space(32)),
                _buildFooter(r, theme),
                SizedBox(height: r.space(40)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin(AuthController controller) async {
    if (controller.formKey.currentState?.validate() ?? false) {
      final success = await controller.login();
      if (success) {
        controller.navigateAfterAuth(false);
      }
    }
  }

  Widget _buildOptionsRow(Responsive r, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: r.iconSize(24),
              height: r.iconSize(24),
              child: Checkbox(
                value: false,
                onChanged: (_) {},
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(r.radius(4)),
                ),
                side: BorderSide(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                activeColor: theme.colorScheme.onSurface,
                checkColor: theme.colorScheme.surface,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            SizedBox(width: r.space(8)),
            Text(
              'Se souvenir de moi',
              style: TextStyle(
                fontSize: r.fontSize(14),
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () => Get.toNamed('/forgot-password'),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Mot de passe oublié',
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
    );
  }

  Widget _buildSocialButtons(Responsive r, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SocialButton(
          onTap: () {},
          child: Text(
            'G',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: r.fontSize(20),
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(width: r.space(16)),
        _SocialButton(
          onTap: () {},
          child: Icon(
            Icons.apple,
            size: r.iconSize(24),
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(Responsive r, ThemeData theme) {
    return Column(
      children: [
        Text(
          'Vous n\'avez pas encore de compte ?',
          style: TextStyle(
            fontSize: r.fontSize(15),
            fontWeight: FontWeight.w400,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
        SizedBox(height: r.space(8)),
        TextButton(
          onPressed: () => Get.toNamed(AppRoutes.register),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'S\'inscrire gratuitement.',
            style: TextStyle(
              fontSize: r.fontSize(15),
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
              decoration: TextDecoration.underline,
              decorationColor: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.onTap,
    required this.child,
  });

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: r.iconSize(56),
        height: r.iconSize(56),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.06),
              blurRadius: r.space(12),
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}