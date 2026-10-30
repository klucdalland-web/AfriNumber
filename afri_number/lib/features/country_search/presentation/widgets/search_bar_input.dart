import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

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

    // Couleurs alignées sur la maquette Figma (mode clair)
    final fieldBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF5F4F0);
    final hintColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF4B5563);
    final iconColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final textColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);

    return Container(
      height: r.space(56 * scale),
      padding: EdgeInsets.symmetric(horizontal: r.space(20 * scale)),
      decoration: BoxDecoration(
        color: fieldBg,
        borderRadius: BorderRadius.circular(r.radius(100 * scale)), // pilule
        // Pas de bordure dans la maquette
      ),
      child: Row(
        children: [
          Icon(
            Icons.search, // loupe barrée comme sur Figma
            size: r.iconSize(24 * scale),
            color: iconColor,
          ),
          SizedBox(width: r.space(12 * scale)),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              cursorColor: iconColor,
              style: GoogleFonts.ibmPlexSans(
                fontSize: r.fontSize(16 * scale),
                fontWeight: FontWeight.w400,
                color: textColor,
              ),
              decoration: InputDecoration(
                hintText: 'country.search_hint'.tr,
                hintStyle: GoogleFonts.ibmPlexSans(
                  fontSize: r.fontSize(16 * scale),
                  fontWeight: FontWeight.w400,
                  color: hintColor,
                ),
                isDense: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (searchQuery.isNotEmpty)
            GestureDetector(
              onTap: onClear,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.only(left: r.space(8 * scale)),
                child: Icon(
                  Icons.close_rounded,
                  size: r.iconSize(20 * scale),
                  color: iconColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}