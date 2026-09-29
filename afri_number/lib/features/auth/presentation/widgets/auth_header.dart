import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.moduleLabel,
    this.showBackButton = false,
    this.onBackPressed,
  });

  final String moduleLabel;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (showBackButton)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: IconButton(
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios_new, size: 22),
              style: IconButton.styleFrom(
                backgroundColor: colors.surfaceContainerHighest,
                foregroundColor: colors.onSurface,
                elevation: 2,
                shadowColor: Colors.black.withValues(alpha: 0.1),
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(12),
              ),
            ),
          ),
        _AfriNumberLogo(color: colors.onSurface),
        const SizedBox(height: 8),
        _LoopCurve(color: colors.onSurface),
        Transform.translate(
          offset: const Offset(0, -12),
          child: _ModuleBadge(label: moduleLabel, colors: colors),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _AfriNumberLogo extends StatelessWidget {
  const _AfriNumberLogo({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset('assets/images/afrika.png',width: 35,),
        Text(
          'AfriNumber.',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontWeight: FontWeight.w700,
            fontSize: 28,
            color: color,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _LoopCurve extends StatelessWidget {
  const _LoopCurve({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 60,
      child: CustomPaint(
        painter: _LoopCurvePainter(color),
      ),
    );
  }
}

class _LoopCurvePainter extends CustomPainter {
  _LoopCurvePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final w = size.width;
    final h = size.height;

    path.moveTo(w * 0.05, h * 0.85);
    path.cubicTo(
      w * 0.15, h * 0.15,
      w * 0.45, h * 0.05,
      w * 0.55, h * 0.25,
    );
    path.cubicTo(
      w * 0.65, h * 0.45,
      w * 0.85, h * 0.65,
      w * 0.95, h * 0.35,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LoopCurvePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _ModuleBadge extends StatelessWidget {
  const _ModuleBadge({required this.label, required this.colors});

  final String label;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.26, // ~15 degrees
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ab',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: colors.onSurface,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
