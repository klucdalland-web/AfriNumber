import '../../../../core/responsive/responsive.dart';

// Les maquettes sont dessinées sur un cadre de 440 pt de large, alors que
// `Responsive` part de 393. Ces deux helpers acceptent les valeurs lues dans
// Figma (cadre 440) et les convertissent : le rendu reste proportionnel à la
// largeur de l'écran.
const double _figmaFrameWidth = 440;
const double _responsiveBaseWidth = 393;
const double _ratio = _responsiveBaseWidth / _figmaFrameWidth;

extension ProfileScale on Responsive {
  /// Dimension / espacement / rayon / icône (valeur Figma).
  double u(double figma) => spacing(figma * _ratio);

  /// Taille de police (valeur Figma).
  double f(double figma) => fontSize(figma * _ratio);
}
