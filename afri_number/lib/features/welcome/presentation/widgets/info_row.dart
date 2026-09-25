import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/widgets.dart';

class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.scale,
    required this.title,
    required this.value,
    this.iconColor,
    this.bgColor,
    this.showIcon = true,
  });

  final double scale;
  final String title;
  final String value;
  final Color? iconColor;
  final Color? bgColor;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: GoogleFonts.ibmPlexSans(
            fontSize: r.fontSize(11 * scale),
            fontWeight: FontWeight.w400,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            height: 17 / 13,
          ),
        ),
        SizedBox(height: r.space(showIcon ? 14 * scale : 2 * scale)),
        if (showIcon)
          Row(
            children: [
              Text(
                value,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: r.fontSize(17 * scale),
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                  height: 26 / 20,
                ),
              ),
              SizedBox(width: r.space(10 * scale)),
              Container(
                width: r.widthOf(34 * scale),
                height: r.heightOf(34 * scale),
                decoration: BoxDecoration(
                  color: bgColor ?? theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(r.radius(50 * scale)),
                ),
                child: Center(
                  child: Icon(
                    Icons.visibility_outlined,
                    size: r.iconSize(18 * scale),
                    color: iconColor ?? theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          )
        else
          Text(
            value,
            style: GoogleFonts.ibmPlexSans(
              fontSize: r.fontSize(11 * scale),
              fontWeight: FontWeight.w400,
              color: theme.colorScheme.onSurface,
              height: 17 / 13,
            ),
          ),
      ],
    );
  }
}