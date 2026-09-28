import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import 'profile_scale.dart';

/// Rangée « 03 Numéros actifs │ Abonnement Basique │ 02 Pays ».
///
/// Les colonnes sont positionnées comme dans la maquette : centres à ±156 pt
/// du milieu d'un cadre de 440, séparateurs à ±0,357 (en `Alignment`), ce qui
/// garde les proportions sur toutes les largeurs d'écran.
class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({
    super.key,
    required this.activeNumbers,
    required this.planName,
    required this.countriesCount,
  });

  final int activeNumbers;
  final String planName;
  final int countriesCount;

  static String _two(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    final strong = AppTextStyles.sectionTitle(r.f(17)).copyWith(
      fontWeight: FontWeight.w600,
      height: 1.3,
    );
    final soft = AppTextStyles.sectionTitle(r.f(17)).copyWith(
      fontWeight: FontWeight.w400,
      color: AppColors.statValue,
      height: 1.3,
      fontFeatures: const [FontFeature.oldstyleFigures()],
    );

    Widget column(List<Text> lines) => Column(
          mainAxisSize: MainAxisSize.min,
          children: lines,
        );

    Widget divider(double x) => Align(
          alignment: Alignment(x, 0),
          child: Container(
            width: r.u(1),
            height: r.u(19),
            color: AppColors.statValue,
          ),
        );

    return SizedBox(
      height: r.u(44),
      child: Stack(
        children: [
          Align(
            alignment: const Alignment(-0.709, 0),
            child: column([
              Text(_two(activeNumbers), style: soft),
              Text('Numéros actifs', style: strong),
            ]),
          ),
          Align(
            alignment: Alignment.center,
            child: column([
              Text('Abonnement', style: strong),
              Text(planName, style: soft),
            ]),
          ),
          Align(
            alignment: const Alignment(0.709, 0),
            child: column([
              Text(_two(countriesCount), style: soft),
              Text('Pays', style: strong),
            ]),
          ),
          divider(-0.357),
          divider(0.357),
        ],
      ),
    );
  }
}
