import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/widgets.dart';
import '../widgets/widgets.dart';

class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({
    super.key,
    required this.scale,
  });

  final double scale;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AfriNumber.',
          style: GoogleFonts.zillaSlab(
            fontSize: r.fontSize(32 * scale),
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
            height: 38 / 32,
            letterSpacing: 0,
          ),
        ),
        Transform.rotate(
          angle: -0.15,
          child: SizedBox(
            width: r.widthOf(180 * scale),
            height: r.heightOf(80 * scale),
            child: CustomPaint(painter: LoopPainter()),
          ),
        ),
      ],
    );
  }
}