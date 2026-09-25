import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/widgets.dart';

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
    return Padding(
      padding: EdgeInsets.only(left: r.widthOf(50 * scale)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Votre numéro',
            style: GoogleFonts.ibmPlexSans(
              fontSize: r.fontSize(32 * scale),
              fontWeight: FontWeight.w300,
              color: theme.colorScheme.onSurface,
              height: 47 / 36,
            ),
          ),
          Text(
            'Internationale',
            style: GoogleFonts.ibmPlexSans(
              fontSize: r.fontSize(36 * scale),
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
              height: 52 / 40,
            ),
          ),
          Text(
            'commence ici.',
            style: GoogleFonts.ibmPlexSans(
              fontSize: r.fontSize(32 * scale),
              fontWeight: FontWeight.w300,
              color: theme.colorScheme.onSurface,
              height: 47 / 36,
            ),
          ),
          SizedBox(height: r.space(12 * scale)),
          Text(
            "Votre avenir n'a plus de frontières,\navec AfriNumber",
            style: GoogleFonts.ibmPlexSans(
              fontSize: r.fontSize(22 * scale),
              fontWeight: FontWeight.w300,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
              height: 31 / 24,
            ),
          ),
        ],
      ),
    );
  }
}