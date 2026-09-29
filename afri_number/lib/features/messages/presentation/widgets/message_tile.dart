import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/inbox_item_tile.dart';
import '../../../../core/widgets/service_avatar.dart';
import '../models/message_preview.dart';

/// Carte blanche arrondie d'un aperçu de message.
class MessageTile extends StatelessWidget {
  const MessageTile({super.key, required this.message, this.onTap});

  final MessagePreview message;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InboxItemTile(
        onTap: onTap,
        leading: ServiceAvatar(
          label: message.sender,
          assetPath: message.logoAsset,
          icon: message.fallbackIcon,
          iconColor: message.fallbackIconColor ?? AppColors.textPrimary,
          fill: message.fillAvatar,
        ),
        title: message.sender,
        preview: message.preview,
        timeLabel: message.timeLabel,
        isUnread: message.isUnread,
        trailingBadge: message.isTranslated
            ? const Icon(
                Icons.language_rounded,
                size: 16,
                color: AppColors.textPrimary,
              )
            : null,
      ),
    );
  }
}
