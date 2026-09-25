import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/widgets/widgets.dart';
import 'decorative_line.dart';
import 'dot_indicator.dart';

class WelcomeFooter extends StatelessWidget {
  const WelcomeFooter({
    super.key,
    required this.scale,
    this.onSkip,
  });

  final double scale;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                DotIndicator(active: true, scale: scale),
                SizedBox(width: r.space(6 * scale)),
                DotIndicator(active: false, scale: scale),
                SizedBox(width: r.space(6 * scale)),
                DotIndicator(active: false, scale: scale),
              ],
            ),
            _SkipButton(
              scale: scale,
              onTap: onSkip ?? () => Get.offAllNamed(AppRoutes.login),
            ),
          ],
        ),
        SizedBox(height: r.space(16 * scale)),
        DecorativeLine(scale: scale),
      ],
    );
  }
}

class _SkipButton extends StatelessWidget {
  const _SkipButton({
    required this.scale,
    required this.onTap,
  });

  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: r.widthOf(140 * scale),
        height: r.heightOf(56 * scale),
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface,
          borderRadius: BorderRadius.circular(r.radius(50 * scale)),
        ),
        child: Center(
          child: Text(
            'Passer',
            style: GoogleFonts.ibmPlexSans(
              fontSize: r.fontSize(18 * scale),
              fontWeight: FontWeight.w400,
              color: theme.colorScheme.surface,
              height: 26 / 20,
            ),
          ),
        ),
      ),
    );
  }
}