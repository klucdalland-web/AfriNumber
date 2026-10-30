import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'platform_utils.dart';

/// Bouton icône adaptatif (Material [IconButton] / Cupertino).
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (isApplePlatform) {
      final button = CupertinoButton(
        padding: const EdgeInsets.all(8),
        onPressed: onPressed,
        child: Icon(
          icon,
          color: color ?? Theme.of(context).colorScheme.primary,
          size: 22,
        ),
      );
      if (tooltip == null) return button;
      return Tooltip(message: tooltip!, child: button);
    }

    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, color: color),
    );
  }
}
