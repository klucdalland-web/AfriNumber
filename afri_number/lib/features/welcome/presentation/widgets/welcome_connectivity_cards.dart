import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/widgets.dart';
import 'loop_painter.dart';

class WelcomeConnectivityCards extends StatelessWidget {
  const WelcomeConnectivityCards({
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

    final smsCardWidth = (screenWidth * 0.54).clamp(180.0, 240.0);

    final cardBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);
    final cardBorder = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return SizedBox(
      height: r.heightOf(230 * scale),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Top Squiggly Loop background
          Positioned(
            left: r.space(0),
            top: r.space(0),
            width: r.widthOf(100 * scale),
            height: r.heightOf(60 * scale),
            child: Transform.rotate(
              angle: -0.15,
              child: CustomPaint(
                painter: LoopPainter(
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
                ),
              ),
            ),
          ),

          // 2. Nouveau SMS Card (Top Left)
          Positioned(
            left: 0,
            top: r.heightOf(10 * scale),
            width: smsCardWidth,
            child: Container(
              padding: EdgeInsets.all(r.space(10 * scale)),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(r.radius(16 * scale)),
                border: Border.all(color: cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: r.iconSize(14 * scale),
                            color: const Color(0xFF2563EB),
                          ),
                          SizedBox(width: r.space(4 * scale)),
                          Text(
                            'Nouveau SMS',
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: r.fontSize(11 * scale),
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: r.widthOf(6 * scale),
                        height: r.heightOf(6 * scale),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2563EB),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: r.space(6 * scale)),
                  Container(
                    padding: EdgeInsets.all(r.space(8 * scale)),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(r.radius(10 * scale)),
                    ),
                    child: Text(
                      '“ Hello, how are you? ”',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: r.fontSize(11 * scale),
                        fontStyle: FontStyle.italic,
                        color: subtextColor,
                      ),
                    ),
                  ),
                  SizedBox(height: r.space(6 * scale)),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: r.space(8 * scale),
                        vertical: r.space(4 * scale),
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF312E81) : const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(r.radius(12 * scale)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Traduire',
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: r.fontSize(10 * scale),
                              fontWeight: FontWeight.w700,
                              color: isDark ? const Color(0xFFC7D2FE) : const Color(0xFF4F46E5),
                            ),
                          ),
                          SizedBox(width: r.space(2 * scale)),
                          Icon(
                            Icons.auto_awesome_rounded,
                            size: r.iconSize(11 * scale),
                            color: isDark ? const Color(0xFFC7D2FE) : const Color(0xFF4F46E5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Zéro Data Pill (Top Right)
          Positioned(
            right: 0,
            top: r.heightOf(20 * scale),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: r.space(10 * scale),
                vertical: r.space(6 * scale),
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(r.radius(20 * scale)),
                border: Border.all(
                  color: isDark ? const Color(0xFF78350F) : const Color(0xFFFDE68A),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cell_tower_rounded,
                    size: r.iconSize(14 * scale),
                    color: isDark ? const Color(0xFFFDE68A) : const Color(0xFFD97706),
                  ),
                  SizedBox(width: r.space(4 * scale)),
                  Text(
                    'Zéro Data',
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: r.fontSize(11 * scale),
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Feature Card 1: Traduction IA (Bottom Left)
          Positioned(
            left: 0,
            bottom: 0,
            width: (screenWidth * 0.45).clamp(150.0, 190.0),
            child: Container(
              padding: EdgeInsets.all(r.space(9 * scale)),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(r.radius(14 * scale)),
                border: Border.all(color: cardBorder),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(r.space(6 * scale)),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF312E81) : const Color(0xFFEEF2FF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.translate_rounded,
                      size: r.iconSize(14 * scale),
                      color: isDark ? const Color(0xFFC7D2FE) : const Color(0xFF4F46E5),
                    ),
                  ),
                  SizedBox(width: r.space(6 * scale)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Traduction IA',
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: r.fontSize(10 * scale),
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        Text(
                          'Comprenez vos SMS instantanément.',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: r.fontSize(8.5 * scale),
                            color: subtextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 5. Feature Card 2: Mode Zéro Data (Bottom Right)
          Positioned(
            right: 0,
            bottom: 0,
            width: (screenWidth * 0.45).clamp(150.0, 190.0),
            child: Container(
              padding: EdgeInsets.all(r.space(9 * scale)),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF143823) : const Color(0xFFD1E7DD),
                borderRadius: BorderRadius.circular(r.radius(14 * scale)),
                border: Border.all(
                  color: isDark ? const Color(0xFF1B4D3E) : const Color(0xFFA3CFBB),
                ),
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
                      Icons.signal_cellular_alt_rounded,
                      size: r.iconSize(14 * scale),
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: r.space(6 * scale)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mode Zéro Data',
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: r.fontSize(10 * scale),
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFFE8F5E9) : const Color(0xFF0F5132),
                          ),
                        ),
                        Text(
                          'Continuez même avec réseau limité.',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: r.fontSize(8.5 * scale),
                            color: isDark ? const Color(0xFFC8E6C9) : const Color(0xFF146C43),
                          ),
                        ),
                      ],
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
}
