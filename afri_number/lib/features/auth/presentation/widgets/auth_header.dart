import 'package:flutter/material.dart';

/// Largeur de référence du design (la maquette fait ~437 px de large).
/// Toutes les tailles sont exprimées dans cet espace puis multipliées
/// par un facteur d'échelle calculé selon la largeur disponible.
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

  /// Plafond de l'agrandissement (tablettes, web, grands écrans).
  final double maxScale;

  /// Marges horizontales totales de la page (gauche + droite), pour calculer
  /// la largeur réellement disponible sans LayoutBuilder.
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // MediaQuery plutôt que LayoutBuilder : plus robuste dans un
    // SingleChildScrollView / IntrinsicHeight / Column non borné.
    final available = MediaQuery.sizeOf(context).width - horizontalPadding;
    final s = (available / _kRefWidth).clamp(0.55, maxScale).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showBackButton)
          Padding(
            padding: EdgeInsets.only(bottom: 16 * s),
            child: IconButton(
              onPressed:
              onBackPressed ?? () => Navigator.of(context).pop(),
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
        // FittedBox : sécurité anti-overflow sur écrans très étroits.
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: _Stage(
            scale: s,
            label: moduleLabel,
            colors: colors,
          ),
        ),
        SizedBox(height: 20 * s),
      ],
    );
  }
}

/// Zone contenant la boucle dessinée + le badge incliné qui la chevauche.
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
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        'AfriNumber.',
        style: TextStyle(
          // Slab serif gras. Pour un rendu identique sur tous les OS,
          // utilise google_fonts : GoogleFonts.bitter(...) ou zillaSlab(...)
          fontFamily: 'Georgia',
          fontWeight: FontWeight.w800,
          fontSize: 30 * scale,
          color: color,
          letterSpacing: -0.5,
        ),
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
    // On dessine dans l'espace de référence, puis on met à l'échelle.
    canvas.scale(scale);
    canvas.translate(0, -_kRefCurveTop);

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
    // départ à gauche
      ..moveTo(57, 133)
    // grande courbe vers le bas puis remontée vers la droite
      ..cubicTo(90, 168, 150, 166, 182, 138)
    // montée vers le haut de la boucle
      ..cubicTo(208, 114, 170, 84, 135, 90)
    // côté gauche de la boucle
      ..cubicTo(102, 96, 104, 126, 146, 128)
    // sortie vers le badge (passe derrière)
      ..cubicTo(180, 130, 208, 116, 226, 90)
    // petit trait qui dépasse au-dessus du badge
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
      angle: 0.36, // ~ +20° (sens horaire, comme sur la maquette)
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
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 22 * s,
                color: colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}