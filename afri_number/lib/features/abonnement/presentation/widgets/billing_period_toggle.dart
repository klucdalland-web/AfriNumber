import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/billing_period.dart';

/// Sélecteur de période de facturation (Mensuel / Annuel).
/// Les libellés sont traduits via les clés GetX.
class BillingPeriodToggle extends StatelessWidget {
  const BillingPeriodToggle({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final BillingPeriod selected;
  final ValueChanged<BillingPeriod> onChanged;

  static const _unselectedColor = Color(0xFFC0C0C0);
  static const _selectedColor = Color(0xFF686868);

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return Container(
      padding: EdgeInsets.all(r.space(6)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(r.radius(24)),
      ),
      child: Row(
        children: [
          for (final value in BillingPeriod.values) ...[
            Expanded(child: _segment(context, value)),
            if (value != BillingPeriod.values.last) SizedBox(width: r.space(10)),
          ],
        ],
      ),
    );
  }

  Widget _segment(BuildContext context, BillingPeriod value) {
    final r = context.responsive;
    final isSelected = value == selected;
    final radius = BorderRadius.circular(r.radius(18));

    return Material(
      color: isSelected ? _selectedColor : _unselectedColor,
      borderRadius: radius,
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: radius,
        child: Container(
          height: r.heightOf(52),
          alignment: Alignment.center,
          child: Text(
            // Libellé traduit selon la période (clé GetX)
            value.labelKey.tr,
            style: AppTextStyles.body(
              r.fontSize(16),
              weight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
