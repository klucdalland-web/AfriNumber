import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Pastille ronde d'un service / expéditeur (Google, PayPal, +33…).
///
/// - [assetPath] : logo exporté depuis Figma (PNG). Si l'asset est absent,
///   on retombe sur [icon] puis sur l'initiale de [label] (aucun crash).
/// - [fill] : `true` pour les drapeaux qui remplissent toute la pastille.
class ServiceAvatar extends StatelessWidget {
  const ServiceAvatar({
    super.key,
    required this.label,
    this.assetPath,
    this.icon,
    this.iconColor = AppColors.textPrimary,
    this.size = 40,
    this.fill = false,
    this.backgroundColor = AppColors.background,
  });

  final String label;
  final String? assetPath;
  final IconData? icon;
  final Color iconColor;
  final double size;
  final bool fill;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: _content(),
    );
  }

  Widget _content() {
    final path = assetPath;
    if (path != null) {
      final inner = fill ? size : size * 0.5;
      return Image.asset(
        path,
        width: inner,
        height: inner,
        fit: fill ? BoxFit.cover : BoxFit.contain,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    if (icon != null) {
      return Icon(icon, size: size * 0.5, color: iconColor);
    }
    final initial = label.trim().isEmpty ? '?' : label.trim()[0].toUpperCase();
    return Text(
      initial,
      style: TextStyle(
        fontSize: size * 0.4,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}
