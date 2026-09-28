import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/history_entry.dart';

/// Ligne d'historique : icône, titre + heure, pastille de droite
/// (montant, numéro ou durée).
class HistoryTile extends StatelessWidget {
  const HistoryTile({super.key, required this.entry});

  final HistoryEntry entry;

  IconData get _icon => switch (entry.kind) {
        HistoryKind.topUp => Icons.account_balance_wallet_outlined,
        HistoryKind.purchase => Icons.credit_card_outlined,
        HistoryKind.smsReceived || HistoryKind.smsSent => Icons.drafts_outlined,
        HistoryKind.callOutgoing || HistoryKind.callIncoming => Icons.call_outlined,
      };

  Widget? get _trailing {
    final amount = entry.amount;
    if (amount != null) {
      final label = Formatters.signedAmount(amount);
      return amount >= 0 ? StatusBadge.success(label) : StatusBadge.danger(label);
    }
    if (entry.counterpart != null) return StatusBadge.neutral(entry.counterpart!);
    if (entry.durationMinutes != null) {
      return StatusBadge.neutral('${entry.durationMinutes} min');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final trailing = _trailing;

    return AppCard(
      child: Row(
        children: [
          IconCircle(_icon),
          SizedBox(width: r.space(11)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: AppTextStyles.body(
                    r.fontSize(16),
                    weight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  Formatters.time(entry.date),
                  style: AppTextStyles.body(r.fontSize(14)),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[SizedBox(width: r.space(8)), trailing],
        ],
      ),
    );
  }
}
