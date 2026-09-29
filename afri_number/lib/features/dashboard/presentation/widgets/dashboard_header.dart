import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/widgets.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.scale,
    required this.country,
    this.onNotificationTap,
    this.onProfileTap,
  });

  final double scale;
  final String country;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final pillBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final textColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/images/afrika.png',
                  width: 50 * scale,
                ),
                Text(
                  'AfriNumber.',
                  style: GoogleFonts.zillaSlab(
                    fontSize: r.fontSize(26 * scale),
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            SizedBox(height: r.space(4 * scale)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: r.space(8 * scale),
                vertical: r.space(4 * scale),
              ),
              decoration: BoxDecoration(
                color: pillBg,
                borderRadius: BorderRadius.circular(r.radius(16 * scale)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: r.iconSize(12 * scale),
                    color: const Color(0xFF10B981),
                  ),
                  SizedBox(width: r.space(4 * scale)),
                  Text(
                    country,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: r.fontSize(11 * scale),
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Row(
          children: [
            // Notifications Icon Button
            GestureDetector(
              onTap: onNotificationTap,
              child: Container(
                width: r.widthOf(38 * scale),
                height: r.heightOf(38 * scale),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.notifications_none_rounded,
                    size: r.iconSize(20 * scale),
                    color: textColor,
                  ),
                ),
              ),
            ),
            SizedBox(width: r.space(10 * scale)),

            // Profile Avatar Circle
            GestureDetector(
              onTap: onProfileTap,
              child: Container(
                width: r.widthOf(38 * scale),
                height: r.heightOf(38 * scale),
                decoration: const BoxDecoration(
                  color: Color(0xFFFBC02D),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.person_rounded,
                    size: r.iconSize(22 * scale),
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
