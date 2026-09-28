import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../responsive/responsive.dart';

/// Pastille de statut / montant (« Actif », « + 50 000 MGA », « 12 min »…).
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.background = AppColors.chip,
    this.foreground = AppColors.textSecondary,
    this.weight = FontWeight.w600,
  });

  const StatusBadge.success(this.label, {super.key})
      : background = AppColors.mint,
        foreground = AppColors.ink,
        weight = FontWeight.w600;

  const StatusBadge.danger(this.label, {super.key})
      : background = AppColors.dangerBackground,
        foreground = AppColors.dangerText,
        weight = FontWeight.w600;

  const StatusBadge.neutral(this.label, {super.key})
      : background = AppColors.chip,
        foreground = AppColors.textSecondary,
        weight = FontWeight.w500;

  final String label;
  final Color background;
  final Color foreground;
  final FontWeight weight;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: r.space(10),
        vertical: r.space(4),
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(r.radius(20)),
      ),
      child: Text(
        label,
        style: AppTextStyles.body(
          r.fontSize(14),
          weight: weight,
          color: foreground,
        ),
      ),
    );
  }
}
