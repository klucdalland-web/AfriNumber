import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/history_entry.dart';

class HistoryTile extends StatelessWidget {
  const HistoryTile({super.key, required this.entry});

  final HistoryEntry entry;

  IconData get _icon => switch (entry.kind) {
        HistoryKind.topUp => Icons.account_balance_wallet_rounded,
        HistoryKind.purchase => Icons.phone_android_rounded,
        HistoryKind.smsReceived || HistoryKind.smsSent => Icons.mark_chat_read_rounded,
        HistoryKind.callOutgoing || HistoryKind.callIncoming => Icons.call_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);
    final cardBorder = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final iconBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);

    final amount = entry.amount;
    final isUS = entry.title.toUpperCase().contains('US');
    final isMG = entry.title.toUpperCase().contains('MVOLA') || entry.title.toUpperCase().contains('AIRTEL');

    return Container(
      padding: EdgeInsets.all(r.space(14)),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(r.radius(18)),
        border: Border.all(color: cardBorder),
      ),
      child: Row(
        children: [
          if (isUS)
            const CountryFlagBadge(code: 'US', size: 38)
          else if (isMG)
            const CountryFlagBadge(code: 'MG', size: 38)
          else
            Container(
              width: r.widthOf(38),
              height: r.heightOf(38),
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  _icon,
                  size: r.iconSize(18),
                  color: textColor,
                ),
              ),
            ),
          SizedBox(width: r.space(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: r.fontSize(14),
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                SizedBox(height: r.space(2)),
                Text(
                  Formatters.time(entry.date),
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: r.fontSize(12),
                    fontWeight: FontWeight.w400,
                    color: subtextColor,
                  ),
                ),
              ],
            ),
          ),
          if (amount != null) ...[
            Text(
              Formatters.signedAmount(amount),
              style: GoogleFonts.ibmPlexSans(
                fontSize: r.fontSize(14),
                fontWeight: FontWeight.w700,
                color: amount >= 0
                    ? const Color(0xFF10B981)
                    : (isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A)),
              ),
            ),
          ] else if (entry.counterpart != null) ...[
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: r.space(8),
                vertical: r.space(4),
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(r.radius(8)),
              ),
              child: Text(
                entry.counterpart!,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: r.fontSize(11),
                  fontWeight: FontWeight.w500,
                  color: subtextColor,
                ),
              ),
            ),
          ] else if (entry.durationMinutes != null) ...[
            Text(
              '${entry.durationMinutes} min',
              style: GoogleFonts.ibmPlexSans(
                fontSize: r.fontSize(12),
                fontWeight: FontWeight.w600,
                color: subtextColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
