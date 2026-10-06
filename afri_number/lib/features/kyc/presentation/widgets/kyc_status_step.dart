import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/responsive/responsive.dart';

/// Variante visuelle de l'écran de statut KYC.
enum KycStatusVariant {
  /// Spinner — vérification en cours.
  loading,

  /// Coche verte — identité validée.
  success,

  /// Croix — dossier refusé.
  rejected,
}

/// Écran de statut : vérification en cours, validée, ou refusée.
class KycStatusStep extends StatelessWidget {
  /// Crée un écran de statut.
  const KycStatusStep({
    super.key,
    required this.variant,
    required this.title,
    required this.body,
  });

  /// Variante visuelle.
  final KycStatusVariant variant;

  /// Titre (déjà traduit).
  final String title;

  /// Description (déjà traduite).
  final String body;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color success = AppColors.success;
    final Color error = scheme.error;

    final Color circleColor = switch (variant) {
      KycStatusVariant.loading => scheme.surfaceContainerHighest,
      KycStatusVariant.success => success.withValues(alpha: 0.2),
      KycStatusVariant.rejected => error.withValues(alpha: 0.15),
    };

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: r.space(32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: r.space(64),
              height: r.space(64),
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: switch (variant) {
                  KycStatusVariant.loading => SizedBox(
                      width: r.space(24),
                      height: r.space(24),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  KycStatusVariant.success => Icon(
                      Icons.check_rounded,
                      size: r.space(28),
                      color: success,
                    ),
                  KycStatusVariant.rejected => Icon(
                      Icons.close_rounded,
                      size: r.space(28),
                      color: error,
                    ),
                },
              ),
            ),
            SizedBox(height: r.space(16)),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: r.fontSize(15),
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: r.space(6)),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: r.fontSize(12),
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
