import 'package:flutter/material.dart';

import '../../../../core/widgets/widgets.dart';
import 'loop_painter.dart';

class BottomLoop extends StatelessWidget {
  const BottomLoop({
    super.key,
    required this.scale,
  });

  final double scale;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    return Align(
      alignment: Alignment.centerRight,
      child: Transform.rotate(
        angle: 0.2,
        child: SizedBox(
          width: r.widthOf(120 * scale),
          height: r.heightOf(55 * scale),
          child: CustomPaint(painter: LoopPainter()),
        ),
      ),
    );
  }
}