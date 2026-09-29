import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/inbox_item_tile.dart';
import '../../../../core/widgets/service_avatar.dart';
import '../models/notification_item.dart';

/// Titre de groupe + carte blanche unique dont les lignes sont séparées par un filet.
class NotificationGroupSection extends StatelessWidget {
  const NotificationGroupSection({super.key, required this.group});

  final NotificationGroup group;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(group.title, style: AppTypography.groupTitle),
        const SizedBox(height: 10),
        Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < group.items.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.divider,
                  ),
                _NotificationRow(item: group.items[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({required this.item});

  final NotificationItem item;

  @override
  Widget build(BuildContext context) {
    return InboxItemTile(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12.5),
      leading: ServiceAvatar(label: item.service, assetPath: item.logoAsset),
      title: item.service,
      preview: item.message,
      timeLabel: item.timeLabel,
      isUnread: item.isUnread,
    );
  }
}
