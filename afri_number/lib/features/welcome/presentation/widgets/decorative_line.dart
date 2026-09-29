import 'package:flutter/material.dart';

import '../../../../core/widgets/widgets.dart';

class DecorativeLine extends StatelessWidget {
  const DecorativeLine({
    super.key,
    required this.scale,
  });

  final double scale;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    return Column(
      children: [
        Container(
          width: r.widthOf(120 * scale),
          height: r.heightOf(4 * scale),
          decoration: BoxDecoration(
            color: const Color(0xFFB9C0C9),
            borderRadius: BorderRadius.circular(r.radius(100 * scale)),
          ),
        ),
        SizedBox(height: r.space(8 * scale)),
        Container(
          height: r.heightOf(24 * scale),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
      ],
    );
  }
}