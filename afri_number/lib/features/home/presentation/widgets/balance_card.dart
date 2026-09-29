import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/service_avatar.dart';
import '../models/wallet_card_data.dart';
import 'dotted_world_map.dart';

/// Carte noire « Dollar américain » : solde masquable, numéro virtuel, expiration.
class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.data,
    required this.isBalanceVisible,
    required this.onToggleVisibility,
  });

  final WalletCardData data;
  final bool isBalanceVisible;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    final balanceText = isBalanceVisible
        ? '${data.currencySymbol} ${data.formattedBalance}'
        : '${data.currencySymbol} ••••••';

    return Container(
      height: 178,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          // Carte du monde en points (fond).
          const Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(top: 8),
              child: Opacity(opacity: 0.85, child: DottedWorldMap()),
            ),
          ),
          // Contenu.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ligne devise (légèrement décalée comme sur la maquette).
                Padding(
                  padding: const EdgeInsets.only(left: 9),
                  child: Row(
                    children: [
                      ServiceAvatar(
                        label: data.currencyName,
                        assetPath: data.flagAsset,
                        icon: Icons.flag_rounded,
                        iconColor: Colors.white,
                        size: 22,
                        fill: true,
                        backgroundColor: const Color(0xFF2A2A2A),
                      ),
                      const SizedBox(width: 8),
                      Text(data.currencyName, style: AppTypography.cardCurrency),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text('Votre Balance', style: AppTypography.cardLabel),
                const SizedBox(height: 4),
                Text(balanceText, style: AppTypography.cardBalance),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _CardField(
                      label: 'Numéro virtuel',
                      value: data.virtualNumberMasked,
                    ),
                    const SizedBox(width: 36),
                    _CardField(label: "Date d'expiration", value: data.expiry),
                  ],
                ),
              ],
            ),
          ),
          // Bouton œil (centré horizontalement légèrement à gauche, comme Figma).
          Positioned(
            left: 118,
            top: 62,
            child: _EyeButton(
              isVisible: isBalanceVisible,
              onPressed: onToggleVisibility,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardField extends StatelessWidget {
  const _CardField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTypography.cardLabel),
        const SizedBox(height: 4),
        Text(value, style: AppTypography.cardValue),
      ],
    );
  }
}

class _EyeButton extends StatelessWidget {
  const _EyeButton({required this.isVisible, required this.onPressed});

  final bool isVisible;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF151515),
      shape: CircleBorder(
        side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            isVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
