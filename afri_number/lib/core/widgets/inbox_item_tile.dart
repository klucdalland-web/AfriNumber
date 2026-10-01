import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

/// Ligne d'une boîte de réception (message ou notification) :
/// avatar · titre + heure · aperçu + point non lu / badge.
class InboxItemTile extends StatelessWidget {
  const InboxItemTile({
    super.key,
    required this.leading,
    required this.title,
    required this.preview,
    required this.timeLabel,
    this.isUnread = false,
    this.trailingBadge,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
    this.onTap,
  });

  final Widget leading;
  final String title;
  final String preview;
  final String timeLabel;
  final bool isUnread;

  /// Petit widget après le point non lu (ex. globe « message traduit »).
  final Widget? trailingBadge;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.inboxTitle.copyWith(
                            color: textColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timeLabel,
                        style: AppTypography.inboxTime.copyWith(
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          preview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.inboxPreview.copyWith(
                            color: subtitleColor,
                          ),
                        ),
                      ),
                      if (isUnread) ...[
                        const SizedBox(width: 8),
                        const _UnreadDot(),
                      ],
                      if (trailingBadge != null) ...[
                        const SizedBox(width: 6),
                        trailingBadge!,
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnreadDot extends StatelessWidget {
  const _UnreadDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: AppColors.mint,
        shape: BoxShape.circle,
      ),
    );
  }
}
