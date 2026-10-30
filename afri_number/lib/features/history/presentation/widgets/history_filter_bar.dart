import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/widgets.dart';
import '../../data/models/history_filter.dart';

class HistoryFilterBar extends StatelessWidget {
  const HistoryFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final HistoryFilter selected;
  final ValueChanged<HistoryFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          for (final filter in HistoryFilter.values) ...[
            _FilterChip(
              label: switch (filter) {
                HistoryFilter.all => 'history.filter_all'.tr,
                HistoryFilter.transactions => 'history.filter_transactions'.tr,
                HistoryFilter.calls => 'history.filter_calls'.tr,
                HistoryFilter.sms => 'SMS',
              },
              selected: filter == selected,
              onTap: () => onSelected(filter),
            ),
            if (filter != HistoryFilter.values.last)
              SizedBox(width: r.space(8)),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final activeBg = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final activeText = isDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFF8FAFC);
    final inactiveBg = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFF1F5F9);
    final inactiveText = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: r.space(16),
          vertical: r.space(8),
        ),
        decoration: BoxDecoration(
          color: selected ? activeBg : inactiveBg,
          borderRadius: BorderRadius.circular(r.radius(20)),
          border: Border.all(
            color: selected
                ? activeBg
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.ibmPlexSans(
            fontSize: r.fontSize(13),
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? activeText : inactiveText,
          ),
        ),
      ),
    );
  }
}
