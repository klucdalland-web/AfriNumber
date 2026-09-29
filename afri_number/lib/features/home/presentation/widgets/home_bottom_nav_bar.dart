import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';

/// Barre de navigation basse : l'onglet actif affiche icône + libellé
/// et un trait noir de 2 px en haut ; les autres n'affichent que l'icône.
class HomeBottomNavBar extends StatelessWidget {
  const HomeBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<_NavItemData> _items = [
    _NavItemData(icon: Icons.home_outlined, label: 'Accueil'),
    _NavItemData(icon: Icons.search_rounded, label: 'Recherche'),
    _NavItemData(icon: Icons.pie_chart_outline_rounded, label: 'Statistiques'),
    _NavItemData(icon: Icons.schedule_rounded, label: 'Historique'),
    _NavItemData(icon: Icons.person_outline_rounded, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Padding(
            padding: const EdgeInsets.only(left: 21, right: 16),
            child: Row(
              children: [
                for (var i = 0; i < _items.length; i++)
                  i == 0
                      ? SizedBox(
                          width: 72,
                          child: _NavItem(
                            data: _items[i],
                            selected: currentIndex == i,
                            onTap: () => onTap(i),
                          ),
                        )
                      : Expanded(
                          child: _NavItem(
                            data: _items[i],
                            selected: currentIndex == i,
                            onTap: () => onTap(i),
                          ),
                        ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  final _NavItemData data;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.ink : const Color(0xFF484C52);

    return Semantics(
      button: true,
      selected: selected,
      label: data.label,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            // Trait indicateur de l'onglet actif.
            if (selected)
              const Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: SizedBox(
                  height: 2,
                  child: ColoredBox(color: AppColors.ink),
                ),
              ),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(data.icon, size: 22, color: color),
                  if (selected) ...[
                    const SizedBox(width: 6),
                    Text(data.label, style: AppTypography.navActiveLabel),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
