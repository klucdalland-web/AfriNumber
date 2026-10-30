import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/widgets.dart';
import 'locale_controller.dart';

/// Feuille de sélection de la langue (français / anglais).
Future<void> showLanguageSelector(BuildContext context) {
  final r = context.responsive;
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final controller = Get.find<LocaleController>();

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Obx(
            () => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: r.space(12)),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: r.space(20)),
            _LangOption(
              flagCode: 'FR',
              label: 'Français',
              selected: controller.languageCode == 'fr',
              onTap: () async {
                Navigator.of(sheetContext).pop();
                await controller.change('fr');
              },
            ),
            SizedBox(height: r.space(8)),
            _LangOption(
              flagCode: 'GB',
              label: 'English',
              selected: controller.languageCode == 'en',
              onTap: () async {
                Navigator.of(sheetContext).pop();
                await controller.change('en');
              },
            ),
            SizedBox(height: r.space(20)),
          ],
        ),
      ),
    ),
  );
}

class _LangOption extends StatelessWidget {
  const _LangOption({
    required this.flagCode,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String flagCode;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(r.radius(12)),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: r.space(20),
          vertical: r.space(12),
        ),
        child: Row(
          children: [
            CountryFlagBadge(code: flagCode, size: r.iconSize(28)),
            SizedBox(width: r.space(14)),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.zillaSlab(
                  fontSize: r.fontSize(16),
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            if (selected)
              Icon(
                Icons.check_circle,
                size: r.iconSize(22),
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}