import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/widgets.dart';
import 'loop_painter.dart';

class WelcomePaymentCards extends StatelessWidget {
  const WelcomePaymentCards({
    super.key,
    required this.scale,
    required this.screenWidth,
  });

  final double scale;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardWidth = (screenWidth * 0.58).clamp(200.0, 260.0);

    final cardBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);
    final cardBorder = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final cardBadgeBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final textColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return SizedBox(
      height: r.heightOf(230 * scale),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Decorative Squiggly Loop top-left
          Positioned(
            left: r.space(0),
            top: r.space(5 * scale),
            width: r.widthOf(110 * scale),
            height: r.heightOf(65 * scale),
            child: Transform.rotate(
              angle: -0.1,
              child: CustomPaint(
                painter: LoopPainter(
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
                ),
              ),
            ),
          ),

          // 2. Main Madagascar Payment Card (Top Right)
          Positioned(
            right: 0,
            top: 0,
            width: cardWidth,
            child: Container(
              padding: EdgeInsets.all(r.space(12 * scale)),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(r.radius(20 * scale)),
                border: Border.all(color: cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Country Badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: r.space(8 * scale),
                      vertical: r.space(4 * scale),
                    ),
                    decoration: BoxDecoration(
                      color: cardBadgeBg,
                      borderRadius: BorderRadius.circular(r.radius(20 * scale)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.public_rounded,
                          size: r.iconSize(13 * scale),
                          color: textColor,
                        ),
                        SizedBox(width: r.space(4 * scale)),
                        Text(
                          'Madagascar',
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: r.fontSize(11 * scale),
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: r.space(8 * scale)),
                  Text(
                    'Montant',
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: r.fontSize(10 * scale),
                      fontWeight: FontWeight.w500,
                      color: subtextColor,
                    ),
                  ),
                  SizedBox(height: r.space(2 * scale)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '25 000 Ar',
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: r.fontSize(16 * scale),
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: r.space(6 * scale),
                          vertical: r.space(3 * scale),
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF064E3B) : const Color(0xFFD1E7DD),
                          borderRadius: BorderRadius.circular(r.radius(10 * scale)),
                        ),
                        child: Text(
                          'Local',
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: r.fontSize(9 * scale),
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFFA7F3D0) : const Color(0xFF0F5132),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 3. Mobile Money Payment Methods Floating Row (Lower Left)
          Positioned(
            left: r.widthOf(10 * scale),
            top: r.heightOf(85 * scale),
            child: Row(
              children: [
                _buildProviderBadge(
                  r: r,
                  scale: scale,
                  name: 'MVola',
                  color: const Color(0xFF00875A),
                  textColor: Colors.white,
                  icon: Icons.account_balance_wallet_rounded,
                ),
                SizedBox(width: r.space(6 * scale)),
                _buildProviderBadge(
                  r: r,
                  scale: scale,
                  name: 'Airtel',
                  color: const Color(0xFFD32F2F),
                  textColor: Colors.white,
                  icon: Icons.phone_android_rounded,
                ),
                SizedBox(width: r.space(6 * scale)),
                _buildProviderBadge(
                  r: r,
                  scale: scale,
                  name: 'MTN',
                  color: const Color(0xFFFBC02D),
                  textColor: Colors.black,
                  icon: Icons.flash_on_rounded,
                ),
              ],
            ),
          ),

          // 4. Floating Button: Payer → (Lower Right)
          Positioned(
            right: r.space(10 * scale),
            top: r.heightOf(85 * scale),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: r.space(14 * scale),
                vertical: r.space(7 * scale),
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(r.radius(25 * scale)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Payer',
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: r.fontSize(12 * scale),
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    ),
                  ),
                  SizedBox(width: r.space(4 * scale)),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: r.iconSize(14 * scale),
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  ),
                ],
              ),
            ),
          ),

          // 5. Highlight Message Banner at the bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: r.space(12 * scale),
                vertical: r.space(10 * scale),
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF143823) : const Color(0xFFD1E7DD),
                borderRadius: BorderRadius.circular(r.radius(16 * scale)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(r.space(6 * scale)),
                    decoration: const BoxDecoration(
                      color: Color(0xFF198754),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.credit_card_off_rounded,
                      size: r.iconSize(14 * scale),
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: r.space(10 * scale)),
                  Expanded(
                    child: Text(
                      'Pas besoin de carte bancaire internationale pour utiliser AfriNumber.',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: r.fontSize(11 * scale),
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFE8F5E9) : const Color(0xFF0F5132),
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderBadge({
    required dynamic r,
    required double scale,
    required String name,
    required Color color,
    required Color textColor,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: r.space(8 * scale),
        vertical: r.space(5 * scale),
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(r.radius(12 * scale)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: r.iconSize(11 * scale), color: textColor),
          SizedBox(width: r.space(3 * scale)),
          Text(
            name,
            style: GoogleFonts.ibmPlexSans(
              fontSize: r.fontSize(10 * scale),
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
