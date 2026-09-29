import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/service_avatar.dart';

/// En-tête de l'accueil : logo « AfriNumber. », chip pays, cloche, avatar.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.country,
    required this.onNotificationsTap,
    this.onAvatarTap,
    this.countryFlagAsset,
  });

  final String country;
  final String? countryFlagAsset;
  final VoidCallback onNotificationsTap;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('AfriNumber.', style: AppTypography.logo),
              const SizedBox(height: 8),
              _CountryChip(label: country, flagAsset: countryFlagAsset),
            ],
          ),
        ),
        InkResponse(
          onTap: onNotificationsTap,
          radius: 24,
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 24,
              color: AppColors.ink,
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(onTap: onAvatarTap, child: const _ProfileAvatar()),
      ],
    );
  }
}

class _CountryChip extends StatelessWidget {
  const _CountryChip({required this.label, this.flagAsset});

  final String label;
  final String? flagAsset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 3, 10, 3),
      decoration: BoxDecoration(
        color: AppColors.chip,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ServiceAvatar(
            label: label,
            assetPath: flagAsset,
            size: 16,
            fill: true,
            backgroundColor: const Color(0xFFD9D9D9),
          ),
          const SizedBox(width: 6),
          Text(label, style: AppTypography.chip),
        ],
      ),
    );
  }
}

/// Avatar profil 40 px. Dépose la photo dans [assetPath] ; tant qu'elle
/// n'existe pas, on dessine le badge teal/jaune de la maquette.
class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  static const String assetPath = 'assets/images/avatar.png';

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: 40,
        height: 40,
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const _FallbackAvatar(),
        ),
      ),
    );
  }
}

class _FallbackAvatar extends StatelessWidget {
  const _FallbackAvatar();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Color(0xFF0C8F8F)),
        Positioned(
          left: 8,
          top: 8,
          right: -8,
          bottom: -8,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: Color(0xFFFFAD08),
              shape: BoxShape.circle,
            ),
            child: Align(
              alignment: const Alignment(-0.35, -0.3),
              child: Icon(
                Icons.sentiment_satisfied_alt_rounded,
                size: 14,
                color: Colors.black.withValues(alpha: 0.75),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
