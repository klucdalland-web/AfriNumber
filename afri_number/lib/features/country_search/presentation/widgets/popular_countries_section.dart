import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/widgets.dart';
import '../../domain/models/country_item.dart';

class PopularCountriesSection extends StatelessWidget {
  const PopularCountriesSection({
    super.key,
    required this.scale,
    required this.countries,
    this.onCountryTap,
  });

  final double scale;
  final List<CountryItem> countries;
  final ValueChanged<CountryItem>? onCountryTap;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);
    final cardBorder = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final badgeBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final textColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pays populaires',
          style: GoogleFonts.zillaSlab(
            fontSize: r.fontSize(20 * scale),
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: r.space(12 * scale)),
        SizedBox(
          height: r.heightOf(125 * scale),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: countries.length,
            separatorBuilder: (context, index) => SizedBox(width: r.space(12 * scale)),
            itemBuilder: (context, index) {
              final country = countries[index];
              return _buildPopularCard(
                r: r,
                scale: scale,
                country: country,
                cardBg: cardBg,
                cardBorder: cardBorder,
                badgeBg: badgeBg,
                textColor: textColor,
                subtextColor: subtextColor,
                onTap: () => onCountryTap?.call(country),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPopularCard({
    required dynamic r,
    required double scale,
    required CountryItem country,
    required Color cardBg,
    required Color cardBorder,
    required Color badgeBg,
    required Color textColor,
    required Color subtextColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: r.widthOf(115 * scale),
        padding: EdgeInsets.all(r.space(12 * scale)),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(r.radius(20 * scale)),
          border: Border.all(color: cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: r.space(8 * scale),
              offset: Offset(0, r.space(3 * scale)),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CountryFlagBadge(
              code: country.id,
              size: 32 * scale,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  country.name,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: r.fontSize(12 * scale),
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: r.space(2 * scale)),
                Text(
                  country.code,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: r.fontSize(11 * scale),
                    fontWeight: FontWeight.w400,
                    color: subtextColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
