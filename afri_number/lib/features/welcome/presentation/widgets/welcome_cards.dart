import 'package:flutter/material.dart';

import '../../../../core/widgets/widgets.dart';
import 'money_card.dart';
import 'acheter_badge.dart';

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
    return SizedBox(
      height: r.heightOf(320 * scale),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: screenWidth * 0.08,
            top: r.heightOf(20 * scale),
            width: screenWidth * 0.65,
            child: MoneyCard(
              scale: scale,
              backgroundColor: const Color(0xFFBEDFBF),
              flag: '🇬🇧',
              label: 'Livre Sterling',
              balance: '£ 12,289.98',
              cardNumber: '**** 9548',
              balanceIconColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              balanceBgColor: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          Positioned(
            right: screenWidth * 0.05,
            top: 0,
            width: screenWidth * 0.65,
            child: MoneyCard(
              scale: scale,
              backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
              flag: '🇺🇸',
              label: 'Dollar Américain',
              balance: '\$ 40,800.00',
              cardNumber: '**** 9548',
              balanceIconColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              balanceBgColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.05),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: AcheterBadge(scale: scale),
          ),
        ],
      ),
    );
  }
}