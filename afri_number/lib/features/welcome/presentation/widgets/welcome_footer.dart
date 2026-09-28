import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/widgets/widgets.dart';
import 'dot_indicator.dart';

class WelcomeFooter extends StatelessWidget {
  const WelcomeFooter({
    super.key,
    required this.scale,
    this.currentIndex = 0,
    this.pageCount = 3,
    this.onSkip,
    this.onNext,
  });

  final double scale;
  final int currentIndex;
  final int pageCount;
  final VoidCallback? onSkip;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isLastPage = currentIndex == pageCount - 1;
    final skipTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final buttonBgColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final buttonTextColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: List.generate(pageCount, (index) {
            return Padding(
              padding: EdgeInsets.only(
                right: index < pageCount - 1 ? r.space(6 * scale) : 0,
              ),
              child: DotIndicator(
                active: index == currentIndex,
                scale: scale,
              ),
            );
          }),
        ),
        Row(
          children: [
            if (!isLastPage) ...[
              GestureDetector(
                onTap: onSkip ?? () => Get.offAllNamed(AppRoutes.login),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: r.space(12 * scale),
                    vertical: r.space(8 * scale),
                  ),
                  child: Text(
                    'Passer',
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: r.fontSize(14 * scale),
                      fontWeight: FontWeight.w500,
                      color: skipTextColor,
                    ),
                  ),
                ),
              ),
              SizedBox(width: r.space(8 * scale)),
            ],
            GestureDetector(
              onTap: isLastPage
                  ? (onSkip ?? () => Get.offAllNamed(AppRoutes.login))
                  : (onNext ?? () => Get.offAllNamed(AppRoutes.login)),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: r.space(24 * scale),
                  vertical: r.space(12 * scale),
                ),
                decoration: BoxDecoration(
                  color: buttonBgColor,
                  borderRadius: BorderRadius.circular(r.radius(30 * scale)),
                ),
                child: Text(
                  isLastPage ? 'Commencer' : 'Suivant',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: r.fontSize(15 * scale),
                    fontWeight: FontWeight.w600,
                    color: buttonTextColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
