import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/responsive/responsive.dart';

/// En-tête du parcours KYC : retour, titre centré, bouton info.
class KycHeader extends StatelessWidget {
  /// Crée l'en-tête.
  const KycHeader({super.key, required this.onBack, required this.onInfo});

  /// Action du bouton retour.
  final VoidCallback onBack;

  /// Action du bouton info.
  final VoidCallback onInfo;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: r.space(12),
        vertical: r.space(8),
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.chevron_left),
            color: scheme.onSurface,
          ),
          Expanded(
            child: Text(
              'kyc.title'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: r.fontSize(18),
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.surface,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: onInfo,
              icon: const Icon(Icons.info_outline),
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}