import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive.dart';
import '../../domain/models/kyc_progress_status.dart';

/// Indicateur de progression avec un état visuel pour chaque étape.
class KycStepIndicator extends StatelessWidget {
  const KycStepIndicator({super.key, required this.statuses});

  /// État de chaque étape de la progression.
  final List<KycProgressStatus> statuses;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    Color colorFor(KycProgressStatus status) {
      switch (status) {
        case KycProgressStatus.pending:
          // Étape à venir : grisée.
          return scheme.outlineVariant.withValues(alpha: 0.6);

        case KycProgressStatus.active:
          // Étape actuelle : blanche.
          return Colors.white;

        case KycProgressStatus.passed:
          // Étape terminée avec succès.
          return const Color(0xFF2EAD66);

        case KycProgressStatus.failed:
          // Étape ayant rencontré une erreur.
          return scheme.error;
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: r.space(16)),
      child: Row(
        children: List<Widget>.generate(statuses.length, (int i) {
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              height: r.space(3),
              margin: EdgeInsets.only(
                right: i < statuses.length - 1 ? r.space(4) : 0,
              ),
              decoration: BoxDecoration(
                color: colorFor(statuses[i]),
                border: switch (statuses[i]) {
                  KycProgressStatus.pending => null,
                  KycProgressStatus.active => Border.all(
                    color: scheme.primary,
                    width: 1.5,
                  ),
                  KycProgressStatus.passed || KycProgressStatus.failed => null,
                },
                borderRadius: BorderRadius.circular(r.space(2)),
              ),
            ),
          );
        }),
      ),
    );
  }
}
