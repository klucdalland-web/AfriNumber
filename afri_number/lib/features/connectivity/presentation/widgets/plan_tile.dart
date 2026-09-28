import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/data_plan.dart';

/// Carte d'un forfait disponible.
class PlanTile extends StatelessWidget {
  const PlanTile({super.key, required this.plan, this.onTap});

  final DataPlan plan;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return AppCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.name,
                  style: AppTextStyles.body(
                    r.fontSize(16),
                    weight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                Text(plan.description, style: AppTextStyles.body(r.fontSize(14))),
              ],
            ),
          ),
          SizedBox(width: r.space(12)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formatters.amount(plan.price, currency: plan.currency),
                style: AppTextStyles.body(
                  r.fontSize(18),
                  weight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              Text('/ ${plan.period}', style: AppTextStyles.body(r.fontSize(13))),
            ],
          ),
        ],
      ),
    );
  }
}
