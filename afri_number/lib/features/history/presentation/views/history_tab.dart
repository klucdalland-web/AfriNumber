import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../controllers/history_controller.dart';
import '../widgets/history_filter_bar.dart';
import '../widgets/history_tile.dart';

/// Onglet **Historique** — corps de page uniquement (Scaffold et
/// BottomNavigationBar fournis par le layout principal).
class HistoryTab extends GetView<HistoryController> {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return Obx(() {
      final groups = controller.groups;
      final loadingFirst = controller.isLoading.value && controller.entries.isEmpty;

      return TabPage(
        title: 'Historique',
        subtitle: 'Consultez vos transactions, SMS et appels récents.',
        onRefresh: controller.load,
        children: [
          HistoryFilterBar(
            selected: controller.filter.value,
            onSelected: controller.selectFilter,
          ),
          SizedBox(height: r.space(24)),
          if (loadingFirst)
            Padding(
              padding: EdgeInsets.only(top: r.space(60)),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.ink),
              ),
            )
          else if (controller.errorMessage.isNotEmpty && controller.entries.isEmpty)
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
          else if (groups.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: r.space(40)),
              child: Center(
                child: Text(
                  'Aucune activité pour ce filtre.',
                  style: AppTextStyles.body(r.fontSize(15), color: AppColors.textMuted),
                ),
              ),
            )
          else
            for (final group in groups) ...[
              SectionTitle(group.label),
              for (final entry in group.entries) HistoryTile(entry: entry),
              SizedBox(height: r.space(16)),
            ],
        ],
      );
    });
  }
}
