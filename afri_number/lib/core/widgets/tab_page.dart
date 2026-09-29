import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../responsive/responsive.dart';

/// Coquille commune des onglets principaux (Connectivité, Historique,
/// Profil…).
///
/// **Pas de `Scaffold` ni de barre de navigation** : ces onglets sont
/// embarqués dans le layout principal (`IndexedStack` + `BottomNavigationBar`),
/// qui est le seul propriétaire du `Scaffold`. [TabPage] fournit le fond,
/// le titre / sous-titre et la zone défilante.
class TabPage extends StatelessWidget {
  const TabPage({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.onRefresh,
    this.bottomInset = 120,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Future<void> Function()? onRefresh;

  /// Espace réservé en bas de liste pour que le contenu ne passe pas sous la
  /// barre de navigation flottante du layout principal.
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    final list = ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        r.space(18),
        r.space(24),
        r.space(18),
        r.space(bottomInset),
      ),
      children: [
        Text(title, style: AppTextStyles.screenTitle(r.fontSize(28))),
        if (subtitle != null) ...[
          SizedBox(height: r.space(10)),
          Text(
            subtitle!,
            style: AppTextStyles.body(
              r.fontSize(15),
              color: AppColors.textMuted,
              height: 1.35,
            ),
          ),
        ],
        SizedBox(height: r.space(24)),
        ...children,
      ],
    );

    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: onRefresh == null
            ? list
            : RefreshIndicator(
                color: AppColors.ink,
                onRefresh: onRefresh!,
                child: list,
              ),
      ),
    );
  }
}
