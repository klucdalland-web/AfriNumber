import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/data_plan.dart';

class PlanTile extends StatelessWidget {
  const PlanTile({super.key, required this.plan, this.onTap});

  final DataPlan plan;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);
    final cardBorder = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);
    final textColor = isDark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF0F172A);
    final subtextColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final priceColor = isDark
        ? const Color(0xFF60A5FA)
        : const Color(0xFF2563EB);
    final planNameKey = switch (plan.id) {
      'plan-1' => 'connectivity.plan_1',
      'plan-5' => 'connectivity.plan_5',
      'plan-20' => 'connectivity.plan_20',
      _ => null,
    };
    final planDescriptionKey = switch (plan.id) {
      'plan-1' => 'connectivity.plan_1_desc',
      'plan-5' => 'connectivity.plan_5_desc',
      'plan-20' => 'connectivity.plan_20_desc',
      _ => null,
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(r.space(16)),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(r.radius(20)),
          border: Border.all(color: cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: r.space(6),
              offset: Offset(0, r.space(2)),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    planNameKey == null ? plan.name : planNameKey.tr,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: r.fontSize(15),
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: r.space(4)),
                  Text(
                    planDescriptionKey == null
                        ? plan.description
                        : planDescriptionKey.tr,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: r.fontSize(12),
                      fontWeight: FontWeight.w400,
                      color: subtextColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: r.space(14)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Formatters.amount(plan.price, currency: plan.currency),
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: r.fontSize(16),
                    fontWeight: FontWeight.w700,
                    color: priceColor,
                  ),
                ),
                SizedBox(height: r.space(2)),
                Text(
                  '/ ${plan.period}',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: r.fontSize(11),
                    fontWeight: FontWeight.w500,
                    color: subtextColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
