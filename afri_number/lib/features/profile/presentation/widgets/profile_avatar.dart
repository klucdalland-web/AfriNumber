import 'package:flutter/material.dart';

import '../../../../core/widgets/widgets.dart';
import 'profile_scale.dart';

/// Avatar illustré de la maquette : disque turquoise, disque orange décalé et
/// visage souriant. Dessiné en vectoriel (aucune image à embarquer).
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, this.size = 128});

  /// Diamètre (valeur Figma).
  final double size;

  @override
  Widget build(BuildContext context) {
    final diameter = context.responsive.u(size);
    return SizedBox(
      width: diameter,
      height: diameter,
      child: const CustomPaint(painter: _AvatarPainter()),
    );
  }
}

class _AvatarPainter extends CustomPainter {
  const _AvatarPainter();

  static const _teal = Color(0xFF0C8F8F);
  static const _orange = Color(0xFFFFAD08);
  static const _ink = Color(0xFF030303);

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(radius, radius);

    // Les deux disques sont découpés par le disque extérieur.
    canvas
      ..save()
      ..clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius)))
      ..drawCircle(center, radius, Paint()..color = _teal)
      ..drawCircle(
        center + Offset(radius * 0.158, radius * 0.092),
        radius * 0.908,
        Paint()..color = _orange,
      )
      ..restore();

    final ink = Paint()..color = _ink;
    Rect eye(double dx) => Rect.fromCenter(
          center: center + Offset(dx * radius, -0.336 * radius),
          width: radius * 0.078,
          height: radius * 0.11,
        );
    canvas
      ..drawOval(eye(-0.406), ink)
      ..drawOval(eye(-0.070), ink);

    final smile = Path()
      ..moveTo(center.dx - 0.398 * radius, center.dy - 0.059 * radius)
      ..quadraticBezierTo(
        center.dx - 0.2245 * radius,
        center.dy + 0.035 * radius,
        center.dx - 0.051 * radius,
        center.dy - 0.059 * radius,
      );
    canvas.drawPath(
      smile,
      Paint()
        ..color = _ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.022
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
