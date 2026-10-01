import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/inbox_item_tile.dart';
import '../../../../core/widgets/service_avatar.dart';
import '../models/message_preview.dart';

/// Carte arrondie d'un aperçu de message, adaptée au mode clair/sombre.
class MessageTile extends StatelessWidget {
  const MessageTile({super.key, required this.message, this.onTap});

  final MessagePreview message;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final tileBg = isDark ? const Color(0xFF1E293B) : AppColors.surface;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFF0F0F0);

    return Container(
      decoration: BoxDecoration(
        color: tileBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InboxItemTile(
          onTap: onTap,
          leading: ServiceAvatar(
            label: message.sender,
            assetPath: message.logoAsset,
            icon: message.fallbackIcon,
            iconColor: message.fallbackIconColor ?? theme.colorScheme.onSurface,
            fill: message.fillAvatar,
          ),
          title: message.sender,
          preview: message.preview,
          timeLabel: message.timeLabel,
          isUnread: message.isUnread,
          trailingBadge: message.isTranslated
              ? Icon(
                  Icons.language_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurface,
                )
              : null,
        ),
      ),
    );
  }
}
