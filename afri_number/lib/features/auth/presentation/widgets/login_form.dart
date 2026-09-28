import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/widgets/widgets.dart';
import '../controllers/auth_controller.dart';
import 'social_auth_buttons.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    final controller = Get.find<AuthController>();

    return Form(
      key: controller.loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'De Retour !',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: r.space(8)),
          Text(
            'Heureux de vous revoir ! Connectez-vous pour continuer là où vous vous êtes arrêté.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
              height: 1.4,
            ),
          ),
          _ErrorBanner(controller: controller),

          const Spacer(),

          CustomTextField(
            hintText: 'Téléphone ou Email',
            icon: Icons.call_outlined,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            controller: controller.phoneController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Ce champ est requis';
              }
              return null;
            },
          ),
          SizedBox(height: r.space(14)),
          CustomTextField(
            hintText: 'Mot de passe',
            icon: Icons.lock_outline,
            isPassword: true,
            textInputAction: TextInputAction.done,
            controller: controller.passwordController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Le mot de passe est requis';
              }
              if (value.length < 6) {
                return 'Minimum 6 caractères';
              }
              return null;
            },
            onSubmitted: (_) => controller.login(),
          ),
          SizedBox(height: r.space(12)),
          _OptionsRow(controller: controller),

          const Spacer(),

          const SocialAuthButtons(),
          SizedBox(height: r.space(16)),
          Obx(
            () => AppButton.primary(
              label: 'Connexion',
              isLoading: controller.isLoading.value,
              onPressed: controller.login,
              backgroundColor: theme.colorScheme.onSurface,
              foregroundColor: theme.colorScheme.surface,
              radius: r.radius(28),
              height: r.heightOf(52),
            ),
          ),

          const Spacer(),

          _Footer(),
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
              margin: EdgeInsets.only(top: r.space(12)),
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

class _OptionsRow extends StatelessWidget {
  const _OptionsRow({required this.controller});

  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: r.iconSize(24),
                height: r.iconSize(24),
                child: Obx(
                  () => Checkbox(
                    value: controller.rememberMe.value,
                    onChanged: (value) => controller.toggleRememberMe(value ?? false),
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
              ),
              SizedBox(width: r.space(8)),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Se souvenir de moi',
                    style: TextStyle(
                      fontSize: r.fontSize(14),
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: r.space(8)),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: AppButton.text(
              label: 'Mot de passe oublié',
              onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
              foregroundColor: theme.colorScheme.onSurface,
              underline: true,
            ),
          ),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          'Vous n\'avez pas encore de compte ?',
          style: TextStyle(
            fontSize: r.fontSize(14),
            fontWeight: FontWeight.w400,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
        SizedBox(height: r.space(4)),
        AppButton.text(
          label: 'S\'inscrire gratuitement.',
          onPressed: () => Get.toNamed(AppRoutes.register),
          foregroundColor: theme.colorScheme.onSurface,
          underline: true,
        ),
      ],
    );
  }
}
