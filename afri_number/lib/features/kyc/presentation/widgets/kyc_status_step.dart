import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/responsive/responsive.dart';

/// Écran de statut : vérification en cours (spinner) ou identité vérifiée (coche).
class KycStatusStep extends StatelessWidget {
  /// Crée un écran de statut.
  const KycStatusStep({
    super.key,
    required this.isLoading,
    required this.title,
    required this.body,
  });

  /// `true` affiche le spinner, `false` affiche la coche verte.
  final bool isLoading;

  /// Titre (déjà traduit).
  final String title;

  /// Description (déjà traduite).
  final String body;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color success = AppColors.success;

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
                color: isLoading
                    ? scheme.surfaceContainerHighest
                    : success.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isLoading
                    ? SizedBox(
                  width: r.space(24),
                  height: r.space(24),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: scheme.onSurfaceVariant,
                  ),
                )
                    : Icon(
                  Icons.check_rounded,
                  size: r.space(28),
                  color: success,
                ),
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