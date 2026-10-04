import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive.dart';

/// Indicateur de progression à 3 segments.
class KycStepIndicator extends StatelessWidget {
  /// Crée l'indicateur ; [current] est l'index (0..2) du segment actif.
  const KycStepIndicator({super.key, required this.current});

  /// Segment actif.
  final int current;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: r.space(16)),
      child: Row(
        children: List<Widget>.generate(3, (int i) {
          return Expanded(
            child: Container(
              height: r.space(3),
              margin: EdgeInsets.only(right: i < 2 ? r.space(4) : 0),
              decoration: BoxDecoration(
                color: i == current
                    ? scheme.onSurface
                    : scheme.outlineVariant,
                borderRadius: BorderRadius.circular(r.space(2)),
              ),
            ),
          );
        }),
      ),
    );
  }
}