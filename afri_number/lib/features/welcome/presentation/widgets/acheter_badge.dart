import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/widgets.dart';

class AcheterBadge extends StatelessWidget {
  const AcheterBadge({
    super.key,
    required this.scale,
  });

  final double scale;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    return Transform.rotate(
      angle: -0.12,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: r.space(20 * scale),
          vertical: r.space(10 * scale),
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(r.radius(50 * scale)),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.08),
              blurRadius: r.space(12 * scale),
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.rotate(
              angle: 0.12,
              child: Icon(
                Icons.keyboard_arrow_down,
                size: r.iconSize(22 * scale),
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(width: r.space(8 * scale)),
            Transform.rotate(
              angle: 0.12,
              child: Text(
                'Acheter',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: r.fontSize(18 * scale),
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                  height: 26 / 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}