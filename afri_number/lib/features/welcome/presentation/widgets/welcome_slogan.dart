import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/widgets.dart';
import 'loop_painter.dart';

class WelcomeSlogan extends StatelessWidget {
  const WelcomeSlogan({
    super.key,
    required this.scale,
  });

  final double scale;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Votre numéro',
              style: GoogleFonts.zillaSlab(
                fontSize: r.fontSize(28 * scale),
                fontWeight: FontWeight.w300,
                color: theme.colorScheme.onSurface,
                height: 1.15,
              ),
            ),
            Text(
              'Internationale',
              style: GoogleFonts.zillaSlab(
                fontSize: r.fontSize(36 * scale),
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
                height: 1.15,
              ),
            ),
            Text(
              'commence ici.',
              style: GoogleFonts.zillaSlab(
                fontSize: r.fontSize(28 * scale),
                fontWeight: FontWeight.w300,
                color: theme.colorScheme.onSurface,
                height: 1.15,
              ),
            ),
            SizedBox(height: r.space(12 * scale)),
            Text(
              "Votre avenir n'a plus de frontières,\navec AfriNumber",
              style: GoogleFonts.ibmPlexSans(
                fontSize: r.fontSize(14 * scale),
                fontWeight: FontWeight.w400,
                color: subtitleColor,
                height: 1.35,
              ),
            ),
          ],
        ),

        // Bottom squiggly loop doodle positioned to the right
        Positioned(
          right: 0,
          bottom: -r.heightOf(10 * scale),
          width: r.widthOf(110 * scale),
          height: r.heightOf(60 * scale),
          child: Transform.rotate(
            angle: 0.15,
            child: CustomPaint(
              painter: LoopPainter(
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
