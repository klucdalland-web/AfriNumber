import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/widgets.dart';
import '../../domain/models/country_item.dart';

class CountryListTile extends StatelessWidget {
  const CountryListTile({
    super.key,
    required this.scale,
    required this.country,
    this.onTap,
  });

  final double scale;
  final CountryItem country;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);
    final cardBorder = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final badgeBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final textColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final pillBg = isDark ? const Color(0xFF064E3B) : const Color(0xFFD1E7DD);
    final pillTextColor = isDark ? const Color(0xFFA7F3D0) : const Color(0xFF0F5132);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: r.space(14 * scale),
          vertical: r.space(12 * scale),
        ),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(r.radius(18 * scale)),
          border: Border.all(color: cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: r.space(6 * scale),
              offset: Offset(0, r.space(2 * scale)),
            ),
          ],
        ),
        child: Row(
          children: [
            // Circular Country Icon Badge
            Container(
              width: r.widthOf(36 * scale),
              height: r.heightOf(36 * scale),
              decoration: BoxDecoration(
                color: badgeBg,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  country.icon,
                  size: r.iconSize(18 * scale),
                  color: textColor,
                ),
              ),
            ),
            SizedBox(width: r.space(12 * scale)),

            // Name + Code
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    country.name,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: r.fontSize(14 * scale),
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: r.space(2 * scale)),
                  Text(
                    country.code,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: r.fontSize(12 * scale),
                      fontWeight: FontWeight.w400,
                      color: subtextColor,
                    ),
                  ),
                ],
              ),
            ),

            // Number of available numbers pill + chevron
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: r.space(10 * scale),
                vertical: r.space(5 * scale),
              ),
              decoration: BoxDecoration(
                color: pillBg,
                borderRadius: BorderRadius.circular(r.radius(14 * scale)),
              ),
              child: Text(
                _formatNumber(country.availableNumbers),
                style: GoogleFonts.ibmPlexSans(
                  fontSize: r.fontSize(12 * scale),
                  fontWeight: FontWeight.w700,
                  color: pillTextColor,
                ),
              ),
            ),
            SizedBox(width: r.space(8 * scale)),
            Icon(
              Icons.chevron_right_rounded,
              size: r.iconSize(20 * scale),
              color: subtextColor,
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      final thousands = number ~/ 1000;
      final remainder = number % 1000;
      final remainderStr = remainder.toString().padLeft(3, '0');
      return '$thousands $remainderStr';
    }
    return number.toString();
  }
}
