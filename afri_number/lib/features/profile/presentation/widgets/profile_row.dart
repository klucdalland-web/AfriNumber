import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import 'profile_scale.dart';

/// Ligne de la carte : pastille (icône ou drapeau), libellé gris, valeur
/// noire, puis [trailing] (chevron ou interrupteur).
class ProfileRow extends StatelessWidget {
  const ProfileRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.leading,
    this.trailing,
    this.onTap,
  }) : assert(icon != null || leading != null, 'Fournir icon ou leading');

  final String label;
  final String value;

  /// Icône Material dans la pastille (ignoré si [leading] est fourni).
  final IconData? icon;

  /// Widget personnalisé dans la pastille (ex. drapeau).
  final Widget? leading;

  final Widget? trailing;
  final VoidCallback? onTap;

  /// Chevron des lignes qui mènent à un sous-écran.
  static Widget chevron(BuildContext context) => Icon(
        Icons.chevron_right,
        size: context.responsive.u(24),
        color: AppColors.chevron,
      );

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final radius = BorderRadius.circular(r.u(22));

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Row(
          children: [
            Container(
              width: r.u(44),
              height: r.u(44),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.chip,
                shape: BoxShape.circle,
              ),
              child: leading ??
                  Icon(icon, size: r.u(22), color: AppColors.ink),
            ),
            SizedBox(width: r.u(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body(
                      r.f(13),
                      color: AppColors.textHint,
                      height: 1.25,
                    ),
                  ),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body(
                      r.f(14),
                      color: AppColors.ink,
                      weight: FontWeight.w500,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
