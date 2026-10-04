import 'package:flutter/material.dart';

/// Design tokens extraits des maquettes Figma (onglets Connectivité,
/// Historique, Profil). Valeurs mesurées directement sur les maquettes.
abstract class AppColors {
  /// Fond des écrans (maquette : #F2F2F2).
  static const Color background = Color(0xFFF2F2F2);

  /// Cartes / surfaces.
  static const Color surface = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF34C759);
  /// Noir principal (textes, carte Zéro Data, chip actif, boutons).
  static const Color ink = Color(0xFF030303);

  /// Texte secondaire (sous-titres de cartes, horaires).
  static const Color textSecondary = Color(0xFF484C52);

  /// Texte atténué (sous-titre d'écran).
  static const Color textMuted = Color(0xFF797979);

  /// Vert menthe (badge Actif, toggle, montants positifs).
  static const Color mint = Color(0xFFBEDFBF);

  /// Fond des pastilles neutres et des icônes rondes.
  static const Color chip = Color(0xFFF2F2F2);

  /// Libellés discrets des lignes de réglages (« Numéro de téléphone »…).
  static const Color textHint = Color(0xFF818181);

  /// Valeurs grises de la rangée de statistiques du Profil.
  static const Color statValue = Color(0xFF7B7B7B);

  /// Identifiant sous le nom (@claudio_arthur_008).
  static const Color handle = Color(0xFFB6B6B6);

  /// Chevrons des lignes navigables.
  static const Color chevron = Color(0xFFC0C0C0);

  /// Bouton de déconnexion.
  static const Color logoutBackground = Color(0xFFE2C2C7);
  static const Color logoutForeground = Color(0xFFA2001D);

  /// Montants négatifs.
  static const Color dangerBackground = Color(0xFFFEE2E2);
  static const Color dangerText = Color(0xFFEF4444);
  static const Color textPrimary = Color(0xFF222222);
  static const Color textTertiary = Color(0xFFA6A6A6);
  static const Color divider = Color(0xFFF2F2F2);
  static const Color mapDot = Color(0xFF4A4A4A);
  static const Color mintDark = Color(0xFF3D483E);
}
