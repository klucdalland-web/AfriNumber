import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/widgets/widgets.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Connexion',
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppText.headline('Page Connexion'),
            const SizedBox(height: 8),
            const AppText.body('Formulaire à brancher sur l’API'),
            const SizedBox(height: 48),
            AppButton.primary(
              label: 'Suivant — Dashboard',
              onPressed: () => Get.offAllNamed(AppRoutes.dashboard),
            ),
            const SizedBox(height: 12),
            AppButton.outlined(
              label: 'Pas de compte ? S’inscrire',
              onPressed: () => Get.toNamed(AppRoutes.register),
            ),
            const SizedBox(height: 12),
            AppButton.text(
              label: 'Retour accueil',
              onPressed: () => Get.offAllNamed(AppRoutes.welcome),
            ),
          ],
        ),
      ),
    );
  }
}
