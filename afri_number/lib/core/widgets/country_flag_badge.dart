import 'package:flutter/material.dart';

import '../responsive/responsive.dart';

/// True vector flag badge supporting major countries (MG, FR, US, UK, CA, DE, CI, SN, CM).
/// Renders crisp vector graphics using CustomPainter without emojis or raster images.
class CountryFlagBadge extends StatelessWidget {
  const CountryFlagBadge({
    super.key,
    required this.code,
    this.size = 24.0,
    this.showBorder = true,
  });

  /// Country code (e.g. 'MG', 'FR', 'US', 'UK', 'CA', 'DE', 'CI', 'SN', 'CM').
  final String code;

  /// Diameter/size of the flag.
  final double size;

  /// Optional subtle border around the flag.
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final responsiveSize = context.responsive.widthOf(size);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: responsiveSize,
      height: responsiveSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                width: 1,
              )
            : null,
      ),
      child: ClipOval(
        child: CustomPaint(
          size: Size(responsiveSize, responsiveSize),
          painter: _VectorFlagPainter(code.toUpperCase()),
        ),
      ),
    );
  }
}

class _VectorFlagPainter extends CustomPainter {
  const _VectorFlagPainter(this.code);

  final String code;

  // Colors
  static const _red = Color(0xFFD80027);
  static const _green = Color(0xFF6DA544);
  static const _blue = Color(0xFF0052B4);
  static const _navy = Color(0xFF0A192F);
  static const _white = Color(0xFFFFFFFF);
  static const _yellow = Color(0xFFFFDA44);
  static const _orange = Color(0xFFFF9800);
  static const _black = Color(0xFF262626);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    Paint fill(Color c) => Paint()..color = c;

    switch (code) {
      case 'MG': // Madagascar: White left vertical (1/3), Red top right, Green bottom right
        canvas
          ..drawRect(Rect.fromLTWH(0, 0, w * 0.33, h), fill(_white))
          ..drawRect(Rect.fromLTWH(w * 0.33, 0, w * 0.67, h / 2), fill(_red))
          ..drawRect(Rect.fromLTWH(w * 0.33, h / 2, w * 0.67, h / 2), fill(_green));
        break;

      case 'FR': // France: Blue, White, Red vertical
        canvas
          ..drawRect(Rect.fromLTWH(0, 0, w / 3, h), fill(_blue))
          ..drawRect(Rect.fromLTWH(w / 3, 0, w / 3, h), fill(_white))
          ..drawRect(Rect.fromLTWH(2 * w / 3, 0, w / 3, h), fill(_red));
        break;

      case 'US': // USA: Stripes + Blue Canton
        for (int i = 0; i < 7; i++) {
          final stripeColor = (i % 2 == 0) ? _red : _white;
          canvas.drawRect(Rect.fromLTWH(0, (h / 7) * i, w, h / 7), fill(stripeColor));
        }
        canvas.drawRect(Rect.fromLTWH(0, 0, w * 0.45, h * 0.55), fill(_navy));
        // Simple star center
        final starPaint = fill(_white);
        canvas.drawCircle(Offset(w * 0.225, h * 0.275), w * 0.08, starPaint);
        break;

      case 'UK':
      case 'GB': // United Kingdom: Union Jack simplified
        canvas.drawRect(Rect.fromLTWH(0, 0, w, h), fill(_blue));
        final whitePaint = Paint()
          ..color = _white
          ..strokeWidth = w * 0.22
          ..style = PaintingStyle.stroke;
        final redPaint = Paint()
          ..color = _red
          ..strokeWidth = w * 0.12
          ..style = PaintingStyle.stroke;

        canvas.drawLine(Offset(0, 0), Offset(w, h), whitePaint);
        canvas.drawLine(Offset(w, 0), Offset(0, h), whitePaint);
        canvas.drawLine(Offset(w / 2, 0), Offset(w / 2, h), whitePaint);
        canvas.drawLine(Offset(0, h / 2), Offset(w, h / 2), whitePaint);

        canvas.drawLine(Offset(w / 2, 0), Offset(w / 2, h), redPaint);
        canvas.drawLine(Offset(0, h / 2), Offset(w, h / 2), redPaint);
        break;

      case 'CA': // Canada: Red, White (double width), Red + Leaf shape
        canvas
          ..drawRect(Rect.fromLTWH(0, 0, w * 0.25, h), fill(_red))
          ..drawRect(Rect.fromLTWH(w * 0.25, 0, w * 0.5, h), fill(_white))
          ..drawRect(Rect.fromLTWH(w * 0.75, 0, w * 0.25, h), fill(_red));
        final leafPaint = fill(_red);
        final center = Offset(w * 0.5, h * 0.5);
        canvas.drawCircle(center, w * 0.12, leafPaint);
        break;

      case 'DE': // Germany: Black, Red, Gold horizontal
        canvas
          ..drawRect(Rect.fromLTWH(0, 0, w, h / 3), fill(_black))
          ..drawRect(Rect.fromLTWH(0, h / 3, w, h / 3), fill(_red))
          ..drawRect(Rect.fromLTWH(0, 2 * h / 3, w, h / 3), fill(_yellow));
        break;

      case 'CI': // Côte d'Ivoire: Orange, White, Green vertical
        canvas
          ..drawRect(Rect.fromLTWH(0, 0, w / 3, h), fill(_orange))
          ..drawRect(Rect.fromLTWH(w / 3, 0, w / 3, h), fill(_white))
          ..drawRect(Rect.fromLTWH(2 * w / 3, 0, w / 3, h), fill(_green));
        break;

      case 'SN': // Sénégal: Green, Yellow, Red vertical + Green Star
        canvas
          ..drawRect(Rect.fromLTWH(0, 0, w / 3, h), fill(_green))
          ..drawRect(Rect.fromLTWH(w / 3, 0, w / 3, h), fill(_yellow))
          ..drawRect(Rect.fromLTWH(2 * w / 3, 0, w / 3, h), fill(_red));
        canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.08, fill(_green));
        break;

      case 'CM': // Cameroun: Green, Red, Yellow vertical + Yellow Star
        canvas
          ..drawRect(Rect.fromLTWH(0, 0, w / 3, h), fill(_green))
          ..drawRect(Rect.fromLTWH(w / 3, 0, w / 3, h), fill(_red))
          ..drawRect(Rect.fromLTWH(2 * w / 3, 0, w / 3, h), fill(_yellow));
        canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.08, fill(_yellow));
        break;

      default:
        canvas.drawRect(Rect.fromLTWH(0, 0, w, h), fill(const Color(0xFFCBD5E1)));
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _VectorFlagPainter oldDelegate) =>
      oldDelegate.code != code;
}
