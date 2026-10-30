import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/widgets.dart';

class MoneyBadge extends StatelessWidget {
  const MoneyBadge({
    super.key,
    required this.scale,
    required this.flag,
    required this.label,
  });

  final double scale;
  final String flag;
  final String label;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    return Container(
      height: r.heightOf(36 * scale),
      padding: EdgeInsets.symmetric(horizontal: r.space(12 * scale)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(r.radius(50 * scale)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: r.widthOf(24 * scale),
            height: r.heightOf(16 * scale),
            child: Center(
              child: Text(flag, style: TextStyle(fontSize: r.fontSize(14 * scale))),
            ),
          ),
          SizedBox(width: r.space(8 * scale)),
          Text(
            label,
            style: GoogleFonts.ibmPlexSans(
              fontSize: r.fontSize(15 * scale),
              fontWeight: FontWeight.w300,
              color: theme.colorScheme.onSurface,
              height: 26 / 20,
            ),
          ),
        ],
      ),
    );
  }
}