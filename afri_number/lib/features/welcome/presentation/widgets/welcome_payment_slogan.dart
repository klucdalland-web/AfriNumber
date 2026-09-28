import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/widgets.dart';

class WelcomePaymentSlogan extends StatelessWidget {
  const WelcomePaymentSlogan({
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Votre paiement',
          style: GoogleFonts.zillaSlab(
            fontSize: r.fontSize(28 * scale),
            fontWeight: FontWeight.w300,
            color: theme.colorScheme.onSurface,
            height: 1.15,
          ),
        ),
        Text(
          'Local',
          style: GoogleFonts.zillaSlab(
            fontSize: r.fontSize(36 * scale),
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
            height: 1.15,
          ),
        ),
        Text(
          'devient mondial.',
          style: GoogleFonts.zillaSlab(
            fontSize: r.fontSize(28 * scale),
            fontWeight: FontWeight.w300,
            color: theme.colorScheme.onSurface,
            height: 1.15,
          ),
        ),
        SizedBox(height: r.space(12 * scale)),
        Text(
          'Achetez vos services internationaux avec vos moyens de paiement locaux.',
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
