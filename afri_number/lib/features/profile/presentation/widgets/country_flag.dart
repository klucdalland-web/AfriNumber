import 'package:flutter/material.dart';

import '../../../../core/widgets/widgets.dart';
import 'profile_scale.dart';

/// Drapeau rond dessiné en vectoriel (MG, FR). Autre code : disque neutre.
class CountryFlag extends StatelessWidget {
  const CountryFlag({super.key, required this.code, this.size = 24});

  final String code;

  /// Diamètre (valeur Figma).
  final double size;

  @override
  Widget build(BuildContext context) {
    final diameter = context.responsive.u(size);
    return SizedBox(
      width: diameter,
      height: diameter,
      child: CustomPaint(painter: _FlagPainter(code.toUpperCase())),
    );
  }
}

class _FlagPainter extends CustomPainter {
  const _FlagPainter(this.code);

  final String code;

  static const _red = Color(0xFFD80027);
  static const _green = Color(0xFF6DA544);
  static const _blue = Color(0xFF0052B4);
  static const _white = Color(0xFFFFFFFF);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    Paint fill(Color c) => Paint()..color = c;

    canvas
      ..save()
      ..clipPath(Path()..addOval(Rect.fromLTWH(0, 0, w, h)));

    switch (code) {
      case 'MG':
        canvas
          ..drawRect(Rect.fromLTWH(0, 0, w, h), fill(_white))
          ..drawRect(Rect.fromLTWH(w * 0.32, 0, w * 0.68, h / 2), fill(_red))
          ..drawRect(Rect.fromLTWH(w * 0.32, h / 2, w * 0.68, h / 2), fill(_green));
      case 'FR':
        canvas
          ..drawRect(Rect.fromLTWH(0, 0, w / 3, h), fill(_blue))
          ..drawRect(Rect.fromLTWH(w / 3, 0, w / 3, h), fill(_white))
          ..drawRect(Rect.fromLTWH(2 * w / 3, 0, w / 3, h), fill(_red));
      default:
        canvas.drawRect(Rect.fromLTWH(0, 0, w, h), fill(const Color(0xFFD9D9D9)));
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FlagPainter oldDelegate) => oldDelegate.code != code;
}
