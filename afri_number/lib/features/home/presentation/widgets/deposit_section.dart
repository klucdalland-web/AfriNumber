import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import 'section_header.dart';

/// Section « Dépôt » : titre + lien « Voir tout » et liste de dépôts récents.
/// Les lignes sont fictives tant que la couche Domain n'est pas branchée.
class DepositSection extends StatelessWidget {
  const DepositSection({super.key, this.onSeeAll});

  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Dépôt',
          actionLabel: 'Voir tout',
          onAction: onSeeAll,
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Premier dépôt', style: AppTypography.depositTitle),
                    const SizedBox(height: 2),
                    Text('20 Sep', style: AppTypography.inboxTime),
                  ],
                ),
              ),
              Text('+ £ 500.00', style: AppTypography.depositAmount),
            ],
          ),
        ),
      ],
    );
  }
}
