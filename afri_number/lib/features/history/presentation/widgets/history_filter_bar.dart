import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/history_filter.dart';

/// Rangée de chips Tout / Transactions / SMS / Appels (défile si l'écran est
/// trop étroit).
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
      child: Row(
        children: [
          for (final filter in HistoryFilter.values) ...[
            _FilterChip(
              label: filter.label,
              selected: filter == selected,
              onTap: () => onSelected(filter),
            ),
            if (filter != HistoryFilter.values.last) SizedBox(width: r.space(12)),
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

    return Material(
      color: selected ? AppColors.ink : AppColors.surface,
      borderRadius: BorderRadius.circular(r.radius(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(r.radius(20)),
        child: Container(
          height: r.heightOf(34),
          padding: EdgeInsets.symmetric(horizontal: r.space(15)),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.body(
              r.fontSize(16),
              weight: FontWeight.w500,
              color: selected ? Colors.white : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}
