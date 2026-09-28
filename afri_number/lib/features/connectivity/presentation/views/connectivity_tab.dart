import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../controllers/connectivity_controller.dart';
import '../widgets/plan_tile.dart';
import '../widgets/service_tile.dart';
import '../widgets/zero_data_card.dart';

/// Onglet **Connectivité** — corps de page uniquement (pas de Scaffold ni de
/// BottomNavigationBar : fournis par le layout principal).
class ConnectivityTab extends GetView<ConnectivityController> {
  const ConnectivityTab({super.key});

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return Obx(() {
      final empty = controller.services.isEmpty && controller.plans.isEmpty;

      return TabPage(
        title: 'Connectivité',
        subtitle: 'Gérez vos services de connectivité et restez joignable '
            'partout en Afrique.',
        onRefresh: controller.load,
        children: [
          if (controller.isLoading.value && empty)
            Padding(
              padding: EdgeInsets.only(top: r.space(80)),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.ink),
              ),
            )
          else if (controller.errorMessage.isNotEmpty && empty)
            Center(
              child: Column(
                children: [
                  Text(controller.errorMessage.value),
                  AppButton.text(
                    label: 'Réessayer',
                    onPressed: controller.load,
                    foregroundColor: AppColors.ink,
                    underline: true,
                  ),
                ],
              ),
            )
          else ...[
            ZeroDataCard(
              enabled: controller.zeroDataEnabled.value,
              onChanged: controller.toggleZeroData,
            ),
            SizedBox(height: r.space(28)),
            const SectionTitle('Mes services actifs'),
            for (final service in controller.services) ServiceTile(service: service),
            SizedBox(height: r.space(16)),
            const SectionTitle('Forfaits disponibles'),
            for (final plan in controller.plans) PlanTile(plan: plan),
          ],
        ],
      );
    });
  }
}
