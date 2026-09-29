import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Carte du monde en points, dessinée en fond de la carte de solde.
///
/// Utilise l'export Figma [assetPath] s'il existe (recommandé pour du 1:1),
/// sinon retombe sur un rendu vectoriel approximatif généré par [_DotMapPainter].
class DottedWorldMap extends StatelessWidget {
  const DottedWorldMap({super.key});

  static const String assetPath = 'assets/images/world_dots.png';

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      fit: BoxFit.cover,
      alignment: Alignment.centerRight,
      errorBuilder: (_, __, ___) => const CustomPaint(painter: _DotMapPainter()),
    );
  }
}

class _DotMapPainter extends CustomPainter {
  const _DotMapPainter();

  /// Masque grossier des continents (45 colonnes × 21 lignes).
  static const List<String> _mask = [
    '...##########...####.......##############....',
    '..############..####..####################...',
    '..#############.......#####################..',
    '...############......#####################...',
    '....###########......#####################...',
    '.....##########......####################....',
    '.....#########.......####################....',
    '......#######.......#####################....',
    '.......#####.......####################......',
    '........###........##################.###....',
    '..........#####....#################..##.....',
    '............######....########......#####....',
    '............#######....#######......######...',
    '............#######.....######......#######..',
    '.............######.....######......######...',
    '.............#####......######......#######..',
    '.............#####.......####.......#######..',
    '.............####........####........######.#',
    '.............####......................###...',
    '.............###.............................',
    '.............##..............................',
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final cols = _mask.first.length;
    final step = size.width / cols;
    final yOffset = (size.height - step * _mask.length) / 2;
    final paint = Paint()..color = AppColors.mapDot;

    for (var r = 0; r < _mask.length; r++) {
      for (var c = 0; c < cols; c++) {
        if (_mask[r][c] != '#') continue;
        canvas.drawCircle(
          Offset(c * step + step / 2, yOffset + r * step + step / 2),
          step * 0.2,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
