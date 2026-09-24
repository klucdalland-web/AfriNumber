import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/utils/theme_controller.dart';
import '../../../../core/widgets/widgets.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return AppScaffold(
      title: 'Dashboard',
      actions: [
        AppIconButton(
          tooltip: 'Déconnexion',
          icon: Icons.logout,
          onPressed: () => Get.offAllNamed(AppRoutes.welcome),
        ),
      ],
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppText.headline('Dashboard'),
            SizedBox(height: 8),
            AppText.body('Zone authentifiée — contenu à venir'),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              tooltip: 'Accueil',
              onPressed: () {},
              icon: const Icon(Icons.home_outlined),
            ),
            Obx(
              () => IconButton(
                tooltip: themeController.isDark
                    ? 'Mode clair'
                    : 'Mode sombre',
                onPressed: themeController.toggle,
                icon: Icon(
                  themeController.isDark
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Déconnexion',
              onPressed: () => Get.offAllNamed(AppRoutes.welcome),
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
      ),
    );
  }
}
