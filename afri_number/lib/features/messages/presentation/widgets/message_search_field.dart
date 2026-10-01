import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/widgets.dart';

/// Champ de recherche pilule adaptatif pour l'écran Messages.
class MessageSearchField extends StatelessWidget {
  const MessageSearchField({
    super.key,
    required this.onChanged,
    this.hintText = 'Rechercher un message...',
  });

  final ValueChanged<String> onChanged;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final fieldBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final hintColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final textColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Container(
      height: r.heightOf(48),
      padding: EdgeInsets.symmetric(horizontal: r.space(16)),
      decoration: BoxDecoration(
        color: fieldBg,
        borderRadius: BorderRadius.circular(r.radius(100)),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.search_rounded,
            size: r.iconSize(20),
            color: hintColor,
          ),
          SizedBox(width: r.space(10)),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              cursorColor: textColor,
              style: GoogleFonts.ibmPlexSans(
                fontSize: r.fontSize(14),
                fontWeight: FontWeight.w400,
                color: textColor,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: GoogleFonts.ibmPlexSans(
                  fontSize: r.fontSize(14),
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
        ],
      ),
    );
  }
}
