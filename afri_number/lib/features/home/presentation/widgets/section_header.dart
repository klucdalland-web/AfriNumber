import 'package:flutter/material.dart';

import '../../../../app/theme/app_typography.dart';

/// Titre serif de section avec, en option, un lien à droite (« Voir tout »).
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: Text(title, style: AppTypography.sectionTitle)),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            behavior: HitTestBehavior.opaque,
            child: Text(
              actionLabel!,
              style: AppTypography.link.copyWith(
                decoration: TextDecoration.underline,
              ),
            ),
          ),
      ],
    );
  }
}
