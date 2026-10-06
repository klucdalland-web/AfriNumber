import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/inbox_item_tile.dart';
import '../../../../core/widgets/service_avatar.dart';
import '../../../../core/widgets/widgets.dart';
import '../models/notification_item.dart';

/// Titre de groupe + carte adaptative dont les lignes sont séparées par un filet.
class NotificationGroupSection extends StatelessWidget {
  const NotificationGroupSection({
    super.key,
    required this.group,
    required this.onNotificationTap,
  });

  final NotificationGroup group;
  final ValueChanged<NotificationItem> onNotificationTap;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFF0F0F0);
    final groupTitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          group.title,
          style: GoogleFonts.ibmPlexSans(
            fontSize: r.fontSize(14),
            fontWeight: FontWeight.w600,
            color: groupTitleColor,
          ),
        ),
        SizedBox(height: r.space(10)),
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(r.radius(16)),
            border: Border.all(color: borderColor, width: 1.0),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(r.radius(16)),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < group.items.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: borderColor,
                    ),
                  _NotificationRow(
                    item: group.items[i],
                    onTap: () => onNotificationTap(group.items[i]),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({required this.item, required this.onTap});

  final NotificationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InboxItemTile(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12.5),
      leading: ServiceAvatar(label: item.service),
      title: item.service,
      preview: item.message,
      timeLabel: item.timeLabel,
      isUnread: item.isUnread,
      onTap: onTap,
    );
  }
}
