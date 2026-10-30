import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/widgets.dart';

class VirtualCard extends StatelessWidget {
  const VirtualCard({
    super.key,
    required this.scale,
    required this.currencyName,
    required this.balance,
    required this.virtualNumber,
    required this.expirationDate,
    required this.isBalanceHidden,
    required this.onToggleVisibility,
  });

  final double scale;
  final String currencyName;
  final String balance;
  final String virtualNumber;
  final String expirationDate;
  final bool isBalanceHidden;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(r.space(15 * scale)),
      decoration: BoxDecoration(
        color: const Color(0xFF181A1F),
        borderRadius: BorderRadius.circular(r.radius(24 * scale)),
        border: Border.all(color: const Color(0xFF2C3038)),
      ),
      child: Stack(
        children: [
          Positioned(
              child: Opacity(
                opacity: 0.4,
                child: Image.asset(
                    'assets/images/world-clear.png',
                  width: double.infinity,
                ),
              )
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TOP ROW: Currency Badge
              Row(
                children: [
                  Container(
                    width: r.widthOf(26 * scale),
                    height: r.heightOf(26 * scale),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.public_rounded,
                        size: r.iconSize(14 * scale),
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(width: r.space(8 * scale)),
                  Text(
                    currencyName,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: r.fontSize(15 * scale),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              SizedBox(height: r.space(16 * scale)),

              // 2. MIDDLE ROW: Balance & Eye Toggle
              Text(
                'welcome.balance'.tr,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: r.fontSize(11 * scale),
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF94A3B8),
                ),
              ),
              SizedBox(height: r.space(4 * scale)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBalanceWidget(r),
                  GestureDetector(
                    onTap: onToggleVisibility,
                    child: Container(
                      width: r.widthOf(32 * scale),
                      height: r.heightOf(32 * scale),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2C3038),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          isBalanceHidden
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: r.iconSize(16 * scale),
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: r.space(20 * scale)),

              // 3. BOTTOM ROW: Virtual Number & Expiration Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'welcome.virtual_number'.tr,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: r.fontSize(10 * scale),
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                      SizedBox(height: r.space(2 * scale)),
                      Text(
                        virtualNumber,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: r.fontSize(13 * scale),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'dashboard.expiration_date'.tr,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: r.fontSize(10 * scale),
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                      SizedBox(height: r.space(2 * scale)),
                      Text(
                        expirationDate,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: r.fontSize(13 * scale),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceWidget(Responsive r) {
    if (isBalanceHidden) {
      return Text(
        '••••••••',
        style: GoogleFonts.ibmPlexSans(
          fontSize: r.fontSize(22 * scale),
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 2.0,
        ),
      );
    }

    final cleanStr = balance.replaceAll(',', '');
    final prefixMatch = RegExp(r'^([^\d\s]+)\s*([\d\.]+)').firstMatch(cleanStr);
    if (prefixMatch != null) {
      final prefix = prefixMatch.group(1) ?? '';
      final amount = double.tryParse(prefixMatch.group(2) ?? '');
      if (amount != null) {
        return HackingNumberText(
          targetValue: amount,
          prefix: '$prefix ',
          style: GoogleFonts.ibmPlexSans(
            fontSize: r.fontSize(22 * scale),
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        );
      }
    }

    return Text(
      balance,
      style: GoogleFonts.ibmPlexSans(
        fontSize: r.fontSize(22 * scale),
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }
}
