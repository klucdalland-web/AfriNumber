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
    final isDark = theme.brightness == Brightness.dark;

    final activeColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final inactiveColor = isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: r.widthOf(active ? 20 * scale : 6 * scale),
      height: r.heightOf(6 * scale),
      decoration: BoxDecoration(
        color: active ? activeColor : inactiveColor,
        borderRadius: BorderRadius.circular(r.radius(3 * scale)),
      ),
    );
  }
}
