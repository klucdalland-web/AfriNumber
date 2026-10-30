import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/widgets.dart';
import 'acheter_badge.dart';
import 'loop_painter.dart';
import 'money_card.dart';

class WelcomeCards extends StatelessWidget {
  const WelcomeCards({
    super.key,
    required this.scale,
    required this.screenWidth,
  });

  final double scale;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardWidth = (screenWidth * 0.58).clamp(200.0, 260.0);

    return SizedBox(
      height: r.heightOf(220 * scale),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Top squiggly loop on the left
          Positioned(
            left: r.space(0),
            top: r.space(10 * scale),
            width: r.widthOf(120 * scale),
            height: r.heightOf(75 * scale),
            child: Transform.rotate(
              angle: -0.1,
              child: CustomPaint(
                painter: LoopPainter(
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF0F172A),
                ),
              ),
            ),
          ),

          // 2. Dollar Américain card (Top Right)
          Positioned(
            right: 0,
            top: 0,
            width: cardWidth,
            child: MoneyCard(
              scale: scale,
              backgroundColor: isDark
                  ? const Color(0xFF1E293B)
                  : const Color(0xFFFFFFFF),
              borderColor: isDark
                  ? const Color(0xFF334155)
                  : const Color(0xFFE2E8F0),
              badgeBackgroundColor: isDark
                  ? const Color(0xFF0F172A)
                  : const Color(0xFFF1F5F9),
              flagIcon: Icons.attach_money_rounded,
              label: 'welcome.currency_usd'.tr,
              balance: '\$ 40,800.00',
              cardNumber: '**** 9548',
              textColor: isDark
                  ? const Color(0xFFF8FAFC)
                  : const Color(0xFF0F172A),
              secondaryTextColor: isDark
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF64748B),
            ),
          ),

          // 3. Livre Sterling card (Lower Left)
          Positioned(
            left: r.widthOf(60 * scale),
            top: r.heightOf(65 * scale),
            width: cardWidth,
            child: MoneyCard(
              scale: scale,
              backgroundColor: isDark
                  ? const Color(0xFF143823)
                  : const Color(0xFFC8E6C9),
              borderColor: isDark
                  ? const Color(0xFF1B4D3E)
                  : const Color(0xFFA5D6A7),
              badgeBackgroundColor: isDark
                  ? const Color(0xFF0A2917)
                  : const Color(0xFFA5D6A7),
              flagIcon: Icons.currency_pound_rounded,
              label: 'welcome.currency_gbp'.tr,
              balance: '£ 12,289.98',
              cardNumber: '**** 9548',
              textColor: isDark
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFF1B5E20),
              secondaryTextColor: isDark
                  ? const Color(0xFFA5D6A7)
                  : const Color(0xFF2E7D32),
            ),
          ),

          // 4. Acheter Badge (Floating Bottom Right)
          Positioned(
            right: r.space(10 * scale),
            bottom: 0,
            child: AcheterBadge(scale: scale),
          ),
        ],
      ),
    );
  }
}
