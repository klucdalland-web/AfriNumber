import 'package:flutter/material.dart';

/// Tokens couleur extraits des maquettes Figma (Accueil / Messages / Notifications).
abstract final class AppColors {
  /// Fond des écrans (#F2F2F2).
  static const Color background = Color(0xFFF2F2F2);

  /// Cartes / champs blancs.
  static const Color surface = Colors.white;

  /// Noir profond (carte de solde, boutons ronds, icônes actives).
  static const Color ink = Color(0xFF060606);

  static const Color textPrimary = Color(0xFF222222);
  static const Color textSecondary = Color(0xFF818181);
  static const Color textTertiary = Color(0xFFA6A6A6);

  /// Vert menthe (pastilles d'icônes, badge « non lus », point non lu).
  static const Color mint = Color(0xFFBEDFBF);

  /// Texte sur fond menthe.
  static const Color mintDark = Color(0xFF3D483E);

  /// Chip pays (« Madagascar »).
  static const Color chip = Color(0xFFE6E6E6);

  /// Séparateurs fins dans les listes groupées.
  static const Color divider = Color(0xFFF2F2F2);

  /// Points de la carte du monde sur la carte de solde.
  static const Color mapDot = Color(0xFF4A4A4A);
}
