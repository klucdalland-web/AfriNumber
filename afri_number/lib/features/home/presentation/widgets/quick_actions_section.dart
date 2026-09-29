import 'package:flutter/material.dart';

import '../../../../app/theme/app_typography.dart';
import '../models/quick_action_data.dart';
import 'quick_action_tile.dart';

/// Section « Actions Rapides » : titre, sous-titre et grille 2×2.
class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key, required this.actions});

  final List<QuickActionData> actions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Actions Rapides', style: AppTypography.sectionTitle),
        const SizedBox(height: 6),
        Text(
          'Gérez vos numéros virtuels et vos transactions en un clic.',
          style: AppTypography.sectionCaption,
        ),
        const SizedBox(height: 22),
        LayoutBuilder(
          builder: (context, constraints) {
            const gap = 12.0;
            final tileWidth = (constraints.maxWidth - gap) / 2;
            return Wrap(
              spacing: gap,
              runSpacing: 20,
              children: [
                for (final action in actions)
                  SizedBox(
                    width: tileWidth,
                    height: 93,
                    child: QuickActionTile(data: action),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
