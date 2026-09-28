import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';

/// Carte noire « Mode Zéro Data » avec interrupteur.
class ZeroDataCard extends StatelessWidget {
  const ZeroDataCard({
    super.key,
    required this.enabled,
    required this.onChanged,
  });

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final statusColor = enabled ? AppColors.mint : const Color(0xFF8A8A8A);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(r.space(18)),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(r.radius(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mode Zéro Data',
                      style: AppTextStyles.sectionTitle(r.fontSize(20))
                          .copyWith(color: Colors.white),
                    ),
                    SizedBox(height: r.space(4)),
                    Text(
                      'Recevez vos SMS même sans connexion internet',
                      style: AppTextStyles.body(
                        r.fontSize(14),
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: r.space(12)),
              AppToggle(
                value: enabled,
                onChanged: onChanged,
                inactiveColor: const Color(0xFF4A4A4A),
              ),
            ],
          ),
          SizedBox(height: r.space(14)),
          Row(
            children: [
              Container(
                width: r.iconSize(8),
                height: r.iconSize(8),
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: r.space(8)),
              Text(
                enabled ? 'Actif' : 'Inactif',
                style: AppTextStyles.body(
                  r.fontSize(14),
                  weight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
