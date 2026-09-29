import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/widgets.dart';

class AcheterBadge extends StatelessWidget {
  const AcheterBadge({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    return Transform.rotate(
      angle: -0.12,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: r.space(16 * scale),
          vertical: r.space(8 * scale),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(r.radius(30 * scale)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: r.space(12 * scale),
              offset: Offset(0, r.space(4 * scale)),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.rotate(
              angle: 3.14159,
              child: Icon(
                Icons.reply_rounded,
                size: r.iconSize(18 * scale),
                color: Colors.black,
              ),
            ),
            SizedBox(width: r.space(6 * scale)),
            Text(
              'welcome.buy'.tr,
              style: GoogleFonts.ibmPlexSans(
                fontSize: r.fontSize(15 * scale),
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
