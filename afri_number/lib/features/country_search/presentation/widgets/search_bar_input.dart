import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/widgets.dart';

class SearchBarInput extends StatelessWidget {
  const SearchBarInput({
    super.key,
    required this.scale,
    required this.controller,
    required this.onChanged,
    this.searchQuery = '',
    this.onClear,
  });

  final double scale;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String searchQuery;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final fieldBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final hintColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final textColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: r.space(16 * scale),
        vertical: r.space(4 * scale),
      ),
      decoration: BoxDecoration(
        color: fieldBg,
        borderRadius: BorderRadius.circular(r.radius(30 * scale)),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: r.iconSize(20 * scale),
            color: hintColor,
          ),
          SizedBox(width: r.space(10 * scale)),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: GoogleFonts.ibmPlexSans(
                fontSize: r.fontSize(14 * scale),
                fontWeight: FontWeight.w400,
                color: textColor,
              ),
              decoration: InputDecoration(
                hintText: 'Rechercher un pays ou un indicatif...',
                hintStyle: GoogleFonts.ibmPlexSans(
                  fontSize: r.fontSize(14 * scale),
                  fontWeight: FontWeight.w400,
                  color: hintColor,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: r.space(10 * scale)),
              ),
            ),
          ),
          if (searchQuery.isNotEmpty)
            GestureDetector(
              onTap: onClear,
              child: Icon(
                Icons.close_rounded,
                size: r.iconSize(18 * scale),
                color: hintColor,
              ),
            ),
        ],
      ),
    );
  }
}
