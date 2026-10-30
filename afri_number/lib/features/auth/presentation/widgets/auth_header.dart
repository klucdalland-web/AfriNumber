import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Largeur de référence du design (la maquette fait ~437 px de large).
const double _kRefWidth = 437;

/// Hauteur de la zone "boucle + badge" dans l'espace de référence.
const double _kRefStageHeight = 118;

/// Décalage vertical du tracé pour que la zone commence tout en haut.
const double _kRefCurveTop = 58;

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.moduleLabel,
    this.showBackButton = false,
    this.onBackPressed,
    this.maxScale = 1.25,
    this.horizontalPadding = 48,
  });

  final String moduleLabel;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final double maxScale;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final available = MediaQuery.sizeOf(context).width - horizontalPadding;
    final s = (available / _kRefWidth).clamp(0.55, maxScale).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showBackButton)
          Padding(
            padding: EdgeInsets.only(bottom: 16 * s),
            child: IconButton(
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              icon: Icon(Icons.arrow_back_ios_new, size: 20 * s),
              style: IconButton.styleFrom(
                backgroundColor: colors.surfaceContainerHighest,
                foregroundColor: colors.onSurface,
                elevation: 2,
                shadowColor: Colors.black.withValues(alpha: 0.1),
                shape: const CircleBorder(),
                padding: EdgeInsets.all(12 * s),
              ),
            ),
          ),
        _AfriNumberLogo(color: colors.onSurface, scale: s),
        SizedBox(height: 12 * s),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: _Stage(scale: s, label: moduleLabel, colors: colors),
        ),
        SizedBox(height: 20 * s),
      ],
    );
  }
}

class _Stage extends StatelessWidget {
  const _Stage({
    required this.scale,
    required this.label,
    required this.colors,
  });

  final double scale;
  final String label;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return SizedBox(
      width: _kRefWidth * s,
      height: _kRefStageHeight * s,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _LoopCurvePainter(color: colors.onSurface, scale: s),
            ),
          ),
          // Centre du badge dans la maquette : (303, 112) -> (303, 54) ici.
          Positioned(
            left: 303 * s,
            top: (112 - _kRefCurveTop) * s,
            child: FractionalTranslation(
              translation: const Offset(-0.5, -0.5),
              child: _ModuleBadge(label: label, colors: colors, scale: s),
            ),
          ),
        ],
      ),
    );
  }
}

class _AfriNumberLogo extends StatelessWidget {
  const _AfriNumberLogo({required this.color, required this.scale});

  final Color color;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Text(
      'AfriNumber.',
      style: GoogleFonts.zillaSlab(
        fontSize: 32 * scale,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: -0.5,
      ),
    );
  }
}

class _LoopCurvePainter extends CustomPainter {
  _LoopCurvePainter({required this.color, required this.scale});

  final Color color;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(scale);
    canvas.translate(0, -_kRefCurveTop);

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(57, 133)
      ..cubicTo(90, 168, 150, 166, 182, 138)
      ..cubicTo(208, 114, 170, 84, 135, 90)
      ..cubicTo(102, 96, 104, 126, 146, 128)
      ..cubicTo(180, 130, 208, 116, 226, 90)
      ..lineTo(226, 60);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LoopCurvePainter old) =>
      old.color != color || old.scale != scale;
}

class _ModuleBadge extends StatelessWidget {
  const _ModuleBadge({
    required this.label,
    required this.colors,
    required this.scale,
  });

  final String label;
  final ColorScheme colors;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Transform.rotate(
      angle: 0.36,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 34 * s, vertical: 19 * s),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.surfaceContainerHighest,
              colors.surfaceContainerLowest,
            ],
          ),
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 18 * s,
              offset: Offset(0, 8 * s),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4 * s,
              offset: Offset(0, 1 * s),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ab',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15 * s,
                color: colors.onSurface,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(width: 14 * s),
            Text(
              label,
           style: GoogleFonts.ibmPlexSans(
            fontSize: 24 * s,
    fontWeight: FontWeight.w500,
    color: colors.onSurface,
    height: 1.4,
  ),
            ),
          ],
        ),
      ),
    );
  }
}