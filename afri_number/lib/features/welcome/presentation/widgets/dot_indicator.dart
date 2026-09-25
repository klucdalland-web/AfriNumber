import 'package:flutter/material.dart';

import '../../../../core/widgets/widgets.dart';

class DotIndicator extends StatelessWidget {
  const DotIndicator({
    super.key,
    required this.active,
    required this.scale,
  });

  final bool active;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    return Container(
      width: r.widthOf(active ? 24 * scale : 8 * scale),
      height: r.heightOf(6 * scale),
      decoration: BoxDecoration(
        color: active
            ? theme.colorScheme.onSurface
            : theme.colorScheme.onSurface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(r.radius(3 * scale)),
      ),
    );
  }
}