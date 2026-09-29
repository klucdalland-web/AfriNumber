import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../responsive/responsive.dart';

/// Carte blanche arrondie des maquettes.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final radius = BorderRadius.circular(r.radius(22));

    return Padding(
      padding: margin ?? EdgeInsets.only(bottom: r.space(12)),
      child: Material(
        color: AppColors.surface,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: padding ??
                EdgeInsets.symmetric(
                  horizontal: r.space(14),
                  vertical: r.space(13),
                ),
            child: child,
          ),
        ),
      ),
    );
  }
}
