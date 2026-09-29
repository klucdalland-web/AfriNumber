import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/widgets.dart';

/// Rangée de statistiques du profil (Numéros actifs, Forfait, Pays).
class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({
    super.key,
    required this.activeNumbers,
    required this.planName,
    required this.countriesCount,
  });

  final int activeNumbers;
  final String planName;
  final int countriesCount;

  static String _two(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = isDark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF0F172A);
    final subtextColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final dividerColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);

    Widget item(String value, String label) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.zillaSlab(
              fontSize: r.fontSize(18),
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          SizedBox(height: r.space(2)),
          Text(
            label,
            style: GoogleFonts.ibmPlexSans(
              fontSize: r.fontSize(12),
              fontWeight: FontWeight.w500,
              color: subtextColor,
            ),
          ),
        ],
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: r.space(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: item(_two(activeNumbers), 'profile.active_numbers'.tr),
          ),
          Container(height: r.heightOf(24), width: 1, color: dividerColor),
          Expanded(
            child: item(
              planName == 'Offre Pro' ? 'profile.plan_pro'.tr : planName,
              'Offre',
            ),
          ),
          Container(height: r.heightOf(24), width: 1, color: dividerColor),
          Expanded(child: item(_two(countriesCount), 'Pays rattachés')),
        ],
      ),
    );
  }
}
