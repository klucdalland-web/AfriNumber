import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Pastille ronde d'un service / expéditeur (Google, PayPal, +33…).
class ServiceAvatar extends StatelessWidget {
  const ServiceAvatar({
    super.key,
    required this.label,
    this.assetPath,
    this.icon,
    this.iconColor,
    this.size = 40,
    this.fill = false,
    this.backgroundColor,
  });

  final String label;
  final String? assetPath;
  final IconData? icon;
  final Color? iconColor;
  final double size;
  final bool fill;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = backgroundColor ??
        (isDark ? const Color(0xFF334155) : AppColors.background);
    final icColor = iconColor ??
        (isDark ? theme.colorScheme.onSurface : AppColors.textPrimary);

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: _content(theme, icColor),
    );
  }

  Widget _content(ThemeData theme, Color icColor) {
    final path = assetPath;
    if (path != null) {
      final inner = fill ? size : size * 0.5;
      return Image.asset(
        path,
        width: inner,
        height: inner,
        fit: fill ? BoxFit.cover : BoxFit.contain,
        errorBuilder: (_, _, _) => _fallback(theme, icColor),
      );
    }
    return _fallback(theme, icColor);
  }

  Widget _fallback(ThemeData theme, Color icColor) {
    if (icon != null) {
      return Icon(icon, size: size * 0.5, color: icColor);
    }
    final initial = label.trim().isEmpty ? '?' : label.trim()[0].toUpperCase();
    return Text(
      initial,
      style: TextStyle(
        fontSize: size * 0.4,
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.onSurface,
      ),
    );
  }
}
