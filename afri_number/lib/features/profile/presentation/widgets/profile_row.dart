import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/widgets.dart';

/// Ligne de paramètre adaptative au thème (icône/drapeau, libellé, valeur, trailing).
class ProfileRow extends StatelessWidget {
  const ProfileRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.leading,
    this.trailing,
    this.onTap,
  }) : assert(icon != null || leading != null, 'Fournir icon ou leading');

  final String label;
  final String value;
  final IconData? icon;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  static Widget chevron(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Icon(
      Icons.chevron_right_rounded,
      size: context.responsive.iconSize(22),
      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final chipBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final iconColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final labelColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final valueColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(r.radius(12)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: r.space(4)),
        child: Row(
          children: [
            Container(
              width: r.widthOf(40),
              height: r.heightOf(40),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: chipBg,
                shape: BoxShape.circle,
              ),
              child: leading ??
                  Icon(
                    icon,
                    size: r.iconSize(20),
                    color: iconColor,
                  ),
            ),
            SizedBox(width: r.space(14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: r.fontSize(12),
                      fontWeight: FontWeight.w400,
                      color: labelColor,
                    ),
                  ),
                  SizedBox(height: r.space(2)),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: r.fontSize(14),
                      fontWeight: FontWeight.w600,
                      color: valueColor,
                    ),
                  ),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
