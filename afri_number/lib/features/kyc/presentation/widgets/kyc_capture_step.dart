import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive.dart';

/// Étape de capture (recto, verso ou visage) avec cadre de visée.
class KycCaptureStep extends StatelessWidget {
  /// Crée une étape de capture.
  const KycCaptureStep({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.errorMessage,
  });

  /// Titre (déjà traduit).
  final String title;

  /// Sous-titre (déjà traduit).
  final String subtitle;

  /// Icône centrale du cadre.
  final IconData icon;

  /// Message d'erreur éventuel.
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: r.space(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontSize: r.fontSize(15),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: r.space(2)),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: r.fontSize(12),
              color: scheme.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: Center(
              child: FractionallySizedBox(
                widthFactor: 0.62,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(r.space(48)),
                    ),
                    child: Icon(
                      icon,
                      size: r.space(48),
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (errorMessage != null)
            Padding(
              padding: EdgeInsets.only(bottom: r.space(8)),
              child: Center(
                child: Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: r.fontSize(12),
                    color: scheme.error,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}