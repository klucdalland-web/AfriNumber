import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/plan_feature.dart';

class PlanFeatureRow extends StatelessWidget {
  const PlanFeatureRow({super.key, required this.feature});

  final PlanFeature feature;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final color = feature.included ? AppColors.ink : AppColors.textMuted;

    return Padding(
      padding: EdgeInsets.only(bottom: r.space(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            feature.included
                ? Icons.check_circle_outline
                : Icons.do_not_disturb_on_outlined,
            size: r.iconSize(20),
            color: color,
          ),
          SizedBox(width: r.space(12)),
          Expanded(
            child: Text(
              feature.label,
              style: AppTextStyles.body(
                r.fontSize(15),
                weight: feature.included ? FontWeight.w500 : FontWeight.w400,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
