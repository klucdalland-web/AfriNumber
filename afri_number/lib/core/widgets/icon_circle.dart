import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../responsive/responsive.dart';

/// Icône dans un rond gris clair (pastille de gauche des cartes).
class IconCircle extends StatelessWidget {
  const IconCircle(this.icon, {super.key});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final size = r.iconSize(36);
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.chip,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: r.iconSize(20), color: AppColors.ink),
    );
  }
}
