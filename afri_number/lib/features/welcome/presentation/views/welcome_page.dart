import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/widgets/widgets.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'AfriNumber',
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppText.headline('Accueil'),
            const SizedBox(height: 8),
            const AppText.bodyLarge('Bienvenue sur AfriNumber'),
            const SizedBox(height: 48),
            AppButton.primary(
              label: 'Suivant — Connexion',
              onPressed: () => Get.toNamed(AppRoutes.login),
            ),
            const SizedBox(height: 12),
            AppButton.outlined(
              label: 'Créer un compte',
              onPressed: () => Get.toNamed(AppRoutes.register),
            ),
          ],
        ),
      ),
    );
  }
}
