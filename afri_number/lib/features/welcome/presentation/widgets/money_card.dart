import 'package:flutter/material.dart';

import '../../../../core/widgets/widgets.dart';
import 'money_badge.dart';
import 'info_row.dart';

class MoneyCard extends StatelessWidget {
  const MoneyCard({
    super.key,
    required this.scale,
    required this.backgroundColor,
    required this.flag,
    required this.label,
    required this.balance,
    required this.cardNumber,
    this.balanceIconColor,
    this.balanceBgColor,
  });

  final double scale;
  final Color backgroundColor;
  final String flag;
  final String label;
  final String balance;
  final String cardNumber;
  final Color? balanceIconColor;
  final Color? balanceBgColor;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(r.space(14 * scale)),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(r.radius(28 * scale)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.08),
            blurRadius: r.space(8 * scale),
            offset: Offset(0, r.space(2 * scale)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          MoneyBadge(
            scale: scale,
            flag: flag,
            label: label,
          ),
          SizedBox(height: r.space(14 * scale)),
          InfoRow(
            scale: scale,
            title: 'Votre Balance',
            value: balance,
            iconColor: balanceIconColor,
            bgColor: balanceBgColor,
          ),
          SizedBox(height: r.space(14 * scale)),
          InfoRow(
            scale: scale,
            title: 'Numéro virtuel',
            value: cardNumber,
            showIcon: false,
          ),
        ],
      ),
    );
  }
}