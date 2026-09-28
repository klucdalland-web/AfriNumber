import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/widgets.dart';

class MoneyCard extends StatelessWidget {
  const MoneyCard({
    super.key,
    required this.scale,
    required this.backgroundColor,
    required this.flagIcon,
    required this.label,
    required this.balance,
    required this.cardNumber,
    this.borderColor,
    this.textColor = const Color(0xFF0F172A),
    this.secondaryTextColor = const Color(0xFF64748B),
    this.badgeBackgroundColor = const Color(0xFFF1F5F9),
  });

  final double scale;
  final Color backgroundColor;
  final IconData flagIcon;
  final String label;
  final String balance;
  final String cardNumber;
  final Color? borderColor;
  final Color textColor;
  final Color secondaryTextColor;
  final Color badgeBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return Container(
      padding: EdgeInsets.all(r.space(12 * scale)),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(r.radius(20 * scale)),
        border: borderColor != null ? Border.all(color: borderColor!) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Flag Icon + Label Pill Badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: r.space(8 * scale),
              vertical: r.space(4 * scale),
            ),
            decoration: BoxDecoration(
              color: badgeBackgroundColor,
              borderRadius: BorderRadius.circular(r.radius(20 * scale)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  flagIcon,
                  size: r.iconSize(13 * scale),
                  color: textColor,
                ),
                SizedBox(width: r.space(4 * scale)),
                Text(
                  label,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: r.fontSize(11 * scale),
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: r.space(10 * scale)),

          // Balance Label
          Text(
            'Votre Balance',
            style: GoogleFonts.ibmPlexSans(
              fontSize: r.fontSize(10 * scale),
              fontWeight: FontWeight.w500,
              color: secondaryTextColor,
            ),
          ),
          SizedBox(height: r.space(2 * scale)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                balance,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: r.fontSize(15 * scale),
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              Container(
                width: r.widthOf(26 * scale),
                height: r.heightOf(26 * scale),
                decoration: BoxDecoration(
                  color: badgeBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.visibility_outlined,
                    size: r.iconSize(14 * scale),
                    color: secondaryTextColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: r.space(8 * scale)),

          // Virtual Number Label
          Text(
            'Numéro virtuel',
            style: GoogleFonts.ibmPlexSans(
              fontSize: r.fontSize(9 * scale),
              fontWeight: FontWeight.w500,
              color: secondaryTextColor,
            ),
          ),
          SizedBox(height: r.space(2 * scale)),
          Text(
            cardNumber,
            style: GoogleFonts.ibmPlexSans(
              fontSize: r.fontSize(11 * scale),
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
