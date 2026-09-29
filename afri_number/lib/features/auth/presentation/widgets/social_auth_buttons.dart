import 'package:flutter/material.dart';

import '../../../../core/widgets/widgets.dart';

/// Rangée des boutons de connexion sociale (Google, Apple).
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
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SocialButton(
          onTap: onGooglePressed,
          child: Text(
            'G',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: r.fontSize(20),
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        if (onGooglePressed != null && onApplePressed != null)
          SizedBox(width: r.space(16)),
        if (onApplePressed != null)
          _SocialButton(
            onTap: onApplePressed,
          child: Icon(
            Icons.apple,
            size: r.iconSize(24),
            color: theme.colorScheme.onSurface,
          ),
          ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.onTap,
    required this.child,
  });

  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: r.iconSize(56),
        height: r.iconSize(56),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.06),
              blurRadius: r.space(12),
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}
