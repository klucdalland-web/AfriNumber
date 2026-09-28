import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/widgets.dart';
import '../../domain/models/transaction_item.dart';

class RecentTransactionsSection extends StatelessWidget {
  const RecentTransactionsSection({
    super.key,
    required this.scale,
    required this.transactions,
    this.onViewAllTap,
  });

  final double scale;
  final List<TransactionItem> transactions;
  final VoidCallback? onViewAllTap;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);
    final cardBorder = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final dividerColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Transactions récentes',
              style: GoogleFonts.zillaSlab(
                fontSize: r.fontSize(20 * scale),
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            GestureDetector(
              onTap: onViewAllTap,
              child: Text(
                'Voir tout →',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: r.fontSize(13 * scale),
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: r.space(12 * scale)),

        // Card Container
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(r.radius(20 * scale)),
            border: Border.all(color: cardBorder),
          ),
          child: Column(
            children: List.generate(transactions.length, (index) {
              final tx = transactions[index];
              final isLast = index == transactions.length - 1;

              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(r.space(14 * scale)),
                    child: Row(
                      children: [
                        // Icon Circle
                        Container(
                          width: r.widthOf(36 * scale),
                          height: r.heightOf(36 * scale),
                          decoration: BoxDecoration(
                            color: tx.iconBgColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              tx.icon,
                              size: r.iconSize(18 * scale),
                              color: tx.iconBgColor,
                            ),
                          ),
                        ),
                        SizedBox(width: r.space(12 * scale)),

                        // Title + Subtitle
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tx.title,
                                style: GoogleFonts.ibmPlexSans(
                                  fontSize: r.fontSize(13 * scale),
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              SizedBox(height: r.space(2 * scale)),
                              Text(
                                tx.subtitle,
                                style: GoogleFonts.ibmPlexSans(
                                  fontSize: r.fontSize(11 * scale),
                                  fontWeight: FontWeight.w400,
                                  color: subtextColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Amount + Status
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              tx.amount,
                              style: GoogleFonts.ibmPlexSans(
                                fontSize: r.fontSize(13 * scale),
                                fontWeight: FontWeight.w700,
                                color: tx.isPositive
                                    ? const Color(0xFF10B981)
                                    : textColor,
                              ),
                            ),
                            SizedBox(height: r.space(2 * scale)),
                            Text(
                              tx.status,
                              style: GoogleFonts.ibmPlexSans(
                                fontSize: r.fontSize(11 * scale),
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: dividerColor,
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}
