import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

/// En-tête commun aux écrans « Messages » et « Notifications » :
/// bouton retour, titre, numéro masqué, badge « n non lus » et action optionnelle.
class InboxHeader extends StatelessWidget {
  const InboxHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.unreadCount,
    this.onBack,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final int unreadCount;
  final VoidCallback? onBack;

  /// Widget affiché après le badge (ex. bouton filtre).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: InkResponse(
              onTap: onBack,
              radius: 20,
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.chevron_left_rounded,
                  size: 26,
                  color: AppColors.ink,
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: AppTypography.screenTitle),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTypography.subtitle),
              ],
            ),
          ),
          UnreadBadge(count: unreadCount),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// Badge menthe « 3 non lus ».
class UnreadBadge extends StatelessWidget {
  const UnreadBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text('$count non lus', style: AppTypography.badge),
    );
  }
}

/// Bouton rond blanc (filtre, etc.) de 36 px.
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 36,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: 18, color: AppColors.ink),
        ),
      ),
    );
  }
}
