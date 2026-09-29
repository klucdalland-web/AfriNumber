import 'package:flutter/widgets.dart';

/// Modèle UI d'une action rapide (tuile de la grille 2×2).
class QuickActionData {
  const QuickActionData({
    required this.label,
    required this.icon,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
}
