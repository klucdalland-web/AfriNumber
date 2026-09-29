import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/widgets.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({
    super.key,
    required this.scale,
    this.onBuyNumberTap,
    this.onRechargeTap,
    this.onSmsTap,
    this.onHistoryTap,
  });

  final double scale;
  final VoidCallback? onBuyNumberTap;
  final VoidCallback? onRechargeTap;
  final VoidCallback? onSmsTap;
  final VoidCallback? onHistoryTap;

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions Rapides',
          style: GoogleFonts.zillaSlab(
            fontSize: r.fontSize(20 * scale),
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: r.space(4 * scale)),
        Text(
          'dashboard.quick_actions_subtitle'.tr,
          style: GoogleFonts.ibmPlexSans(
            fontSize: r.fontSize(12 * scale),
            fontWeight: FontWeight.w400,
            color: subtextColor,
          ),
        ),
        SizedBox(height: r.space(14 * scale)),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: r.space(12 * scale),
          crossAxisSpacing: r.space(12 * scale),
          childAspectRatio: 2.2,
          children: [
            _buildActionCard(
              r: r,
              scale: scale,
              label: 'dashboard.buy_number'.tr,
              icon: Icons.phone_in_talk_rounded,
              bgColor: cardBg,
              borderColor: cardBorder,
              textColor: textColor,
              onTap: onBuyNumberTap,
            ),
            _buildActionCard(
              r: r,
              scale: scale,
              label: 'dashboard.recharge'.tr,
              icon: Icons.account_balance_wallet_rounded,
              bgColor: cardBg,
              borderColor: cardBorder,
              textColor: textColor,
              onTap: onRechargeTap,
            ),
            _buildActionCard(
              r: r,
              scale: scale,
              label: 'dashboard.sms'.tr,
              icon: Icons.chat_bubble_outline_rounded,
              bgColor: cardBg,
              borderColor: cardBorder,
              textColor: textColor,
              onTap: onSmsTap,
            ),
            _buildActionCard(
              r: r,
              scale: scale,
              label: 'nav.history'.tr,
              icon: Icons.history_rounded,
              bgColor: cardBg,
              borderColor: cardBorder,
              textColor: textColor,
              onTap: onHistoryTap,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required dynamic r,
    required double scale,
    required String label,
    required IconData icon,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: r.space(12 * scale),
          vertical: r.space(10 * scale),
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(r.radius(16 * scale)),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: r.widthOf(35 * scale),
                  height: r.heightOf(35 * scale),
                  decoration: const BoxDecoration(
                    color: Color(0xFFD1E7DD),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      size: r.iconSize(30* scale),
                      color: const Color(0xFF0F5132),
                    ),
                  ),
                ),
                SizedBox(width: r.space(10 * scale)),
                Container(
                  width: r.widthOf(25 * scale),
                  height: r.heightOf(25 * scale),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.add,
                      size: r.iconSize(15 * scale),
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              label,
              style: GoogleFonts.ibmPlexSans(
                fontSize: r.fontSize(12 * scale),
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
