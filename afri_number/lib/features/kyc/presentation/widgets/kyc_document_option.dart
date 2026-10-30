import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/responsive/responsive.dart';
import '../../domain/models/kyc_document_type.dart';

/// Ligne sélectionnable représentant un type de pièce.
class KycDocumentOption extends StatelessWidget {
  /// Crée une ligne de pièce.
  const KycDocumentOption({
    super.key,
    required this.type,
    required this.selected,
    required this.onTap,
  });

  /// Pièce affichée.
  final KycDocumentType type;

  /// Indique si la pièce est sélectionnée.
  final bool selected;

  /// Action au tap.
  final VoidCallback onTap;

  IconData get _icon {
    switch (type.icon) {
      case 'passport':
        return Icons.flight_outlined;
      case 'driver_license':
        return Icons.directions_car_outlined;
      default:
        return Icons.article_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final BorderRadius radius = BorderRadius.circular(r.space(20));

    return Material(
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: selected ? scheme.onSurface : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: EdgeInsets.all(r.space(12)),
          child: Row(
            children: <Widget>[
              Container(
                width: r.space(36),
                height: r.space(36),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(_icon, size: r.space(18), color: scheme.onSurface),
              ),
              SizedBox(width: r.space(12)),
              Expanded(
                child: Text(
                  type.labelKey.tr,
                  style: TextStyle(fontSize: r.fontSize(13)),
                ),
              ),
              Icon(
                selected ? Icons.check_circle : Icons.chevron_right,
                size: r.space(20),
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}