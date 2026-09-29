import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/widgets.dart';

class WelcomeConnectivitySlogan extends StatelessWidget {
  const WelcomeConnectivitySlogan({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final subtitleColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final headlineLines = 'welcome.slogan_conn'.tr.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          headlineLines[0],
          style: GoogleFonts.zillaSlab(
            fontSize: r.fontSize(28 * scale),
            fontWeight: FontWeight.w300,
            color: theme.colorScheme.onSurface,
            height: 1.15,
          ),
        ),
        Text(
          headlineLines[1],
          style: GoogleFonts.zillaSlab(
            fontSize: r.fontSize(36 * scale),
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
            height: 1.15,
          ),
        ),
        Text(
          headlineLines[2],
          style: GoogleFonts.zillaSlab(
            fontSize: r.fontSize(26 * scale),
            fontWeight: FontWeight.w300,
            color: theme.colorScheme.onSurface,
            height: 1.15,
          ),
        ),
        SizedBox(height: r.space(12 * scale)),
        Text(
          'welcome.slogan_conn_sub'.tr,
          style: GoogleFonts.ibmPlexSans(
            fontSize: r.fontSize(14 * scale),
            fontWeight: FontWeight.w400,
            color: subtitleColor,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
