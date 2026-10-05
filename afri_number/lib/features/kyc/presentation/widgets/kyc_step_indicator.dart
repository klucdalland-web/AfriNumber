import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive.dart';
import '../../domain/models/kyc_progress_status.dart';

/// Indicateur de progression avec un état visuel pour chaque étape.
class KycStepIndicator extends StatelessWidget {
  const KycStepIndicator({super.key, required this.statuses});
enum KycProgressStatus { pending, active, passed, failed } ;
List<KycProgressStatus> get progressStatuses {
  final stages = <KycStep>[
    KycStep.choose,
    KycStep.front,
    if (selectedType.value?.requiresBack == true) KycStep.back,
    KycStep.face,
  ];
  return stages.map((stage) {
    if (stage == step.value && errorMessage.value != null) {
      return KycProgressStatus.failed;
    }
    if (stage == step.value) return KycProgressStatus.active;

    if (stage == KycStep.choose) return KycProgressStatus.passed;
    return _photoQuality[stage] ?? KycProgressStatus.pending;
  }).toList(growable: false);
}

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    Color colorFor(KycProgressStatus status) {
      switch (status) {
        case KycProgressStatus.pending:
          // Étape à venir : grisée
          return scheme.outlineVariant.withValues(alpha: 0.6);
        case KycProgressStatus.active:
          // Étape en cours
          return scheme.primary;
        case KycProgressStatus.passed:
          return const Color(0xFF2EAD66);
        case KycProgressStatus.failed:
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
              height: r.space(3),
              margin: EdgeInsets.only(
                right: i < statuses.length - 1 ? r.space(4) : 0,
              ),
              decoration: BoxDecoration(
                color: colorFor(statuses[i]),
                borderRadius: BorderRadius.circular(r.space(2)),
              ),
            ),
          );
        }),
      ),
    );
  }
}