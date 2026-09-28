import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/widgets.dart';
import '../../domain/models/offer_item.dart';

class RecommendedOffersSection extends StatelessWidget {
  const RecommendedOffersSection({
    super.key,
    required this.scale,
    required this.offers,
    this.onViewAllTap,
    this.onOfferTap,
  });

  final double scale;
  final List<OfferItem> offers;
  final VoidCallback? onViewAllTap;
  final ValueChanged<OfferItem>? onOfferTap;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);
    final cardBorder = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Offres recommandées',
              style: GoogleFonts.zillaSlab(
                fontSize: r.fontSize(20 * scale),
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            GestureDetector(
              onTap: onViewAllTap,
              child: Text(
                'Voir tout →',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: r.fontSize(13 * scale),
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: r.space(12 * scale)),

        // Horizontal List of Offer Cards
        SizedBox(
          height: r.heightOf(130 * scale),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: offers.length,
            separatorBuilder: (context, index) => SizedBox(width: r.space(12 * scale)),
            itemBuilder: (context, index) {
              final offer = offers[index];
              return _buildOfferCard(
                r: r,
                scale: scale,
                offer: offer,
                cardBg: cardBg,
                cardBorder: cardBorder,
                textColor: textColor,
                subtextColor: subtextColor,
                isDark: isDark,
                onTap: () => onOfferTap?.call(offer),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOfferCard({
    required dynamic r,
    required double scale,
    required OfferItem offer,
    required Color cardBg,
    required Color cardBorder,
    required Color textColor,
    required Color subtextColor,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return Container(
      width: r.widthOf(220 * scale),
      padding: EdgeInsets.all(r.space(12 * scale)),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(r.radius(18 * scale)),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(r.space(5 * scale)),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  offer.countryIcon,
                  size: r.iconSize(14 * scale),
                  color: textColor,
                ),
              ),
              SizedBox(width: r.space(6 * scale)),
              Text(
                offer.country,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: r.fontSize(13 * scale),
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                offer.title,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: r.fontSize(11 * scale),
                  fontWeight: FontWeight.w500,
                  color: subtextColor,
                ),
              ),
              SizedBox(height: r.space(2 * scale)),
              Text(
                offer.startingPrice,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: r.fontSize(10 * scale),
                  fontWeight: FontWeight.w400,
                  color: subtextColor,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: r.space(12 * scale),
                  vertical: r.space(5 * scale),
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(r.radius(20 * scale)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Acheter',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: r.fontSize(11 * scale),
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      ),
                    ),
                    SizedBox(width: r.space(3 * scale)),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: r.iconSize(12 * scale),
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
