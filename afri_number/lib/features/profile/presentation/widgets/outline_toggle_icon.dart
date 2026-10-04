import 'package:flutter/material.dart';

import '../../../../core/widgets/widgets.dart';
import 'profile_scale.dart';

/// Pictogramme d'interrupteur « contour » de la maquette (pilule + rond).
/// Purement visuel : c'est la ligne qui le contient qui reçoit le tap.
class OutlineToggleIcon extends StatelessWidget {
  const OutlineToggleIcon({super.key, required this.on});

  final bool on;

  @override
  Widget build(BuildContext context) {
    final size = context.responsive.u(40);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TogglePainter(
          on: on,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _TogglePainter extends CustomPainter {
  const _TogglePainter({required this.on, required this.color});

  final bool on;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // Grille de 24 : pilule de (2,6) à (22,18), rond en (16,12) ou (8,12).
    final s = size.width / 24;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(2 * s, 6 * s, 22 * s, 18 * s),
          Radius.circular(6 * s),
        ),
        paint,
      )
      ..drawCircle(Offset((on ? 16 : 8) * s, 12 * s), 2 * s, paint);
  }

  @override
  bool shouldRepaint(covariant _TogglePainter oldDelegate) =>
      oldDelegate.on != on || oldDelegate.color != color;
}
