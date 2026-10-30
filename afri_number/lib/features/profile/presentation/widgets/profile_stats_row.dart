import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/widgets/widgets.dart';

/// Rangée de statistiques du profil (Numéros actifs, plan, pays).
/// Le bloc du plan ouvre la page de gestion des abonnements.
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

    Widget stat(String value, String label, {VoidCallback? onTap}) {
      final content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
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

      if (onTap == null) return content;

      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: r.space(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: stat(_two(activeNumbers), 'profile.active_numbers'.tr),
          ),
          Container(height: r.heightOf(24), width: 1, color: dividerColor),
          // Bloc du plan actuel cliquable → ouvre la gestion des abonnements.
          Expanded(
            child: stat(
              planName,
              'profile.plan'.tr,
              onTap: () => Get.toNamed(AppRoutes.abonnement),
            ),
          ),
          Container(height: r.heightOf(24), width: 1, color: dividerColor),
          Expanded(child: stat(_two(countriesCount), 'profile.countries_linked'.tr)),
        ],
      ),
    );
  }
}
