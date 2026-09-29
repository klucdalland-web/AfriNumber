import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/widgets.dart';

/// Boutons de connexion sociale (Google, Apple) – style pilule + ronds.
class SocialAuthButtons extends StatelessWidget {
  const SocialAuthButtons({
    super.key,
    this.onGooglePressed,
    this.onApplePressed,
  });

  final VoidCallback? onGooglePressed;
  final VoidCallback? onApplePressed;

  @override
  Widget build(BuildContext context) {
    if (onGooglePressed == null && onApplePressed == null) {
      return const SizedBox.shrink();
    }

    final r = context.responsive;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final dotColor = isDark ? const Color(0xFF4A4A4A) : const Color(0xFFD9D9D9);

    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: r.space(36),
          vertical: r.space(28),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onGooglePressed != null)
              _RoundButton(
                label: 'Continuer avec Google',
                onTap: onGooglePressed!,
                child: _GoogleLogo(size: r.iconSize(30)),
              ),
            if (onGooglePressed != null && onApplePressed != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: r.space(24)),
                child: Container(
                  width: r.space(12),
                  height: r.space(12),
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            if (onApplePressed != null)
              _RoundButton(
                label: 'Continuer avec Apple',
                onTap: onApplePressed!,
                child: _AppleBadge(size: r.iconSize(50)),
              ),
          ],
        ),
      ),
    );
  }
}

/// Rond blanc (surface en sombre) avec ombre douce.
class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.label,
    required this.onTap,
    required this.child,
  });

  final String label;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = r.iconSize(40);

    return Semantics(
      button: true,
      label: label,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
              blurRadius: r.space(14),
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              HapticFeedback.lightImpact();
              onTap();
            },
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

/// Pastille Apple : rond foncé + pomme (inversé en mode sombre).
class _AppleBadge extends StatelessWidget {
  const _AppleBadge({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const navy = Color(0xFF1F2A44);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDark ? Colors.white : navy,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.apple,
        size: size * 0.6,
        color: isDark ? navy : Colors.white,
      ),
    );
  }
}

/// Logo Google "G" multicolore dessiné en code (aucun asset requis).
class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  static const _blue = Color(0xFF4285F4);
  static const _red = Color(0xFFEA4335);
  static const _yellow = Color(0xFFFBBC05);
  static const _green = Color(0xFF34A853);

  static double _rad(double deg) => deg * 3.1415926535897932 / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.2;
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(
      center: center,
      radius: size.width / 2 - stroke / 2,
    );

    Paint arcPaint(Color c) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..isAntiAlias = true;

    canvas.drawArc(rect, _rad(-135), _rad(92), false, arcPaint(_red));
    canvas.drawArc(rect, _rad(135), _rad(90), false, arcPaint(_yellow));
    canvas.drawArc(rect, _rad(45), _rad(90), false, arcPaint(_green));
    canvas.drawArc(rect, _rad(0), _rad(45), false, arcPaint(_blue));

    canvas.drawRect(
      Rect.fromLTRB(
        center.dx,
        center.dy - stroke / 2,
        size.width,
        center.dy + stroke / 2,
      ),
      Paint()..color = _blue,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}