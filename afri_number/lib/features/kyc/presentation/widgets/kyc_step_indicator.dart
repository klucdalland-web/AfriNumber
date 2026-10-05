import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive.dart';
import '../../domain/models/kyc_progress_status.dart';

/// Indicateur de progression avec un état visuel pour chaque étape.
class KycStepIndicator extends StatelessWidget {
  /// Crée l'indicateur à partir de l'état de chaque étape.
  const KycStepIndicator({super.key, required this.statuses});

  /// Statuts ordonnés des segments.
  final List<KycProgressStatus> statuses;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: r.space(16)),
      child: Row(
        children: List<Widget>.generate(statuses.length, (int i) {
          final status = statuses[i];
          return Expanded(
            child: Container(
              height: r.space(3),
              margin: EdgeInsets.only(
                right: i < statuses.length - 1 ? r.space(4) : 0,
              ),
              decoration: BoxDecoration(
                color: switch (status) {
                  KycProgressStatus.pending => Colors.white,
                  KycProgressStatus.passed => const Color(0xFF2EAD66),
                  KycProgressStatus.failed => scheme.error,
                },
                border: status == KycProgressStatus.pending
                    ? Border.all(color: scheme.outlineVariant)
                    : null,
                borderRadius: BorderRadius.circular(r.space(2)),
              ),
            ),
          );
        }),
      ),
    );
  }
}
